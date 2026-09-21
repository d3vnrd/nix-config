{
  inputs,
  lib,
  pkgs,
  hostname,
  vars,
  ...
}: let
  inherit (inputs) nix-config self;
  inherit (nix-config.lib) optionalPaths;
in {
  imports = optionalPaths [(self + "/configuration.nix")];

  config = lib.mkMerge [
    {
      # Setting machine's hostname
      networking.hostName = lib.mkForce hostname;

      # Always enable flake's fetures
      nix.settings = {
        experimental-features = lib.mkForce ["nix-command" "flakes"];
        # trusted-users, substituters, etc.
      };

      nixpkgs.config.allowUnfree = lib.mkDefault true;

      # Global system-wide packages
      environment.systemPackages = with pkgs; [
        curl
      ];

      # Global configurable programs
      programs.git.enable = true;
    }

    (lib.mkIf (inputs ? "home-manager") {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = lib.mkForce {inherit inputs vars;};
      };

      home-manager.users.${vars.username}.imports =
        [nix-config.homeModules.default]
        ++ optionalPaths [(self + "/home.nix")];
    })
  ];
}
