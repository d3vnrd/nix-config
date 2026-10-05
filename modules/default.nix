{
  config,
  inputs,
  lib,
  pkgs,
  hostname,
  ...
}: let
  inherit (inputs) nix-config self;
  inherit (config) _opts;
in {
  # TODO: adding options for host override default values
  options._opts = {};

  # --- Global configurations ---
  config = lib.mkMerge [
    {
      assertions = [];

      nix.settings = {
        experimental-features = lib.mkForce ["nix-command" "flakes"];
        auto-optimise-store = lib.mkDefault true;
        # trusted-users, substituters, etc.
      };

      nixpkgs.config.allowUnfree = lib.mkDefault true;

      networking.hostName = lib.mkForce hostname;

      users.mutableUsers = false;
      users.users.default = {
        inherit (_opts.user) name;
        isNormalUser = true;
        extraGroups = ["wheel"];
        description = "Default host's user";
        openssh.authorizedKeys.keys = _opts.user.sshAuthorizedKeys;
      };

      services.openssh = {
        enable = true;
        # TODO: add initial password and set this to true
        settings.PasswordAuthentication = false;
      };

      programs = {
        git.enable = true;

        vim = {
          enable = true;
          defaultEditor = true;
        };
      };

      environment.systemPackages = with pkgs; [
        curl
      ];
    }

    (lib.optionalAttrs (inputs ? home-manager) {
      home-manager = {
        users = {
          # TODO: Verify if home-manager were able to resolve this correctly
          ${config.users.users.default.name}.imports = [
            nix-config.homeModules.default
          ];
        };

        useGlobalPkgs = lib.mkDefault true;
        useUserPackages = lib.mkDefault true;
        extraSpecialArgs = lib.mkForce {inherit inputs;};
      };
    })

    (lib.optionalAttrs (inputs ? sops-nix) {
      sops.defaultSopsFile = lib.mkDefault "${self}/secrets.yaml";
      sops.age.sshKeyPaths = lib.mkDefault ["/etc/ssh/ssh_host_ed25519_key"];
    })
  ];
}
