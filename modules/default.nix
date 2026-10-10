{
  config,
  inputs,
  lib,
  pkgs,
  hostName,
  ...
}: let
  inherit (inputs) nix-config self;
  inherit (config.default) user;
in {
  # --- Global configurations ---
  config = lib.mkMerge [
    {
      nix.settings = {
        experimental-features = lib.mkForce ["nix-command" "flakes"];
        auto-optimise-store = lib.mkDefault true;
        # trusted-users, substituters, etc.
      };

      nixpkgs.config.allowUnfree = lib.mkDefault true;
      networking.hostName = lib.mkForce hostName;

      programs.git.enable = true;
      environment.systemPackages = with pkgs; [
        curl
      ];
    }

    (lib.optionalAttrs (inputs ? home-manager) {
      home-manager = {
        users.${user.name}.imports = [nix-config.homeModules.default];
        useGlobalPkgs = lib.mkDefault true;
        useUserPackages = lib.mkDefault true;

        /*
        NOTE: do not wrap extraSpecialArgs in mkDefault/mkForce. A priority-wrapped
        definition replaces all plain ones instead of merging with them, so `inputs`
        was silently dropped (or other args overridden) in the Home Manager modules.
        */
        extraSpecialArgs = {inherit inputs;};
      };
    })

    (lib.optionalAttrs (inputs ? sops-nix) {
      sops.defaultSopsFile = lib.mkDefault "${self}/secrets.yaml";
      sops.age.sshKeyPaths = lib.mkDefault ["/etc/ssh/ssh_host_ed25519_key"];
    })
  ];
}
