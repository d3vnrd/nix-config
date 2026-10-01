{
  inputs,
  lib,
  pkgs,
  hostname,
  vars,
  ...
}: let
  inherit (inputs) nix-config self;
  inherit (nix-config.lib.utils) existingPathsRelativeTo;
in {
  imports = existingPathsRelativeTo self [
    "configuration.nix"
    "hardware-configuration.nix"
  ];

  config = lib.mkMerge [
    {
      # Setting machine's hostname
      networking.hostName = lib.mkForce hostname;

      nix.settings = {
        experimental-features = lib.mkForce ["nix-command" "flakes"];
        auto-optimise-store = lib.mkDefault true;
        # trusted-users, substituters, etc.
      };

      nixpkgs.config.allowUnfree = lib.mkDefault true;

      # Global configurable programs
      programs = {
        git.enable = true;

        vim = {
          enable = true;
          defaultEditor = true;
        };
      };

      # Global packages
      environment.systemPackages = with pkgs; [
        curl
      ];
    }

    (lib.optionalAttrs (inputs ? "home-manager") {
      home-manager = {
        useGlobalPkgs = lib.mkDefault true;
        useUserPackages = lib.mkDefault true;
        extraSpecialArgs = lib.mkForce {inherit inputs vars;};
      };

      home-manager.users.${vars.username}.imports =
        [nix-config.homeModules.default]
        ++ (existingPathsRelativeTo self ["home.nix"]);
    })

    (lib.optionalAttrs (inputs ? "sops-nix") {
      sops.defaultSopsFile = lib.mkDefault "${self}/secrets.yaml";
      # Automatically import SSH keys as age keys
      sops.age.sshKeyPaths = lib.mkDefault ["/etc/ssh/ssh_host_ed25519_key"];
    })
  ];
}
