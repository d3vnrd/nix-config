{
  description = "A modular NixOs system built for the road";

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib legacyPackages;

    util = import ./lib lib;
    mkModulesTree = path: util.recursiveScan {inherit path;};
    forAllSystems = lib.genAttrs lib.systems.flakeExposed;
  in {
    inherit util;

    nixosModules = mkModulesTree ./modules/nixos;

    darwinModules = mkModulesTree ./modules/darwin;

    homeModules = mkModulesTree ./modules/home;

    # Used by `nix flake check`
    # checks = forAllSystems (system: {});

    # Used by `nix develop .#<name>`
    devShells = forAllSystems (system: import ./shells legacyPackages.${system});

    # Set formatter used by `nix fmt`
    formatter = forAllSystems (system: legacyPackages.${system}.nixfmt);

    /*
    Nix-config's shared derivations
    doc: https://noogle.dev/f/lib/packagesFromDirectoryRecursive/
    ex: https://codeberg.org/fidgetingbits/introdus/src/branch/main/pkgs
    */
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
    in
      lib.packagesFromDirectoryRecursive {
        /*
        Do not use `newScope` here: it adds `recurseForDerivations` to the
        returned attribute set, which is incompatible with the flake's
        `packages.${system}` interface. Package-to-package dependencies
        are instead provided through the overlay `nix-config` namespace.
        */
        inherit (pkgs) callPackage; # Equivalent to `lib.callPackageWith pkgs`
        directory = ./pkgs;
      });

    # Overlay, consumed by other flakes
    overlays = import ./overlays {inherit inputs lib;};

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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
