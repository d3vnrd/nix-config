{
  inputs,
  lib,
  pkgs,
  hostname,
  ...
}: let
  inherit (inputs) nix-config self;
  inherit (nix-config.util) optionalPath;

  vars = lib.recursiveUpdate (import nix-config) (import self);
in
  {
    imports = optionalPath (self + "/configuration.nix");

    # Adding finalized vars into module's args
    _module.args.vars = vars;

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
  // (lib.mkIf (inputs ? "home-manager") {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = lib.mkForce {inherit inputs vars;};
    };

    home-manager.users.${vars.username}.imports = [
      inputs.homeModules.default
      (optionalPath (self + "/home.nix"))
    ];
  })
