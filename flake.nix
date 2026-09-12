{
  description = "A modular NixOs system built for the road";

  outputs = {nixpkgs, ...}: let
    inherit (nixpkgs) lib legacyPackages;

    util = import ./lib lib;
    scanPath = path: util.recursiveScan {inherit path;};
    forAllSystems = lib.genAttrs lib.systems.flakeExposed;
  in {
    inherit util;

    nixosModules = scanPath ./modules/nixos;

    darwinModules = scanPath ./modules/darwin;

    homeModules = scanPath ./modules/home;

    # Used by `nix develop .#<name>`
    devShells = forAllSystems (system: import ./shells legacyPackages.${system});

    # Set formatter used by `nix fmt`
    formatter = forAllSystems (system: legacyPackages.${system}.nixfmt);

    # Used by `nix flake init -t <flake>`
    templates = import ./templates lib;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
