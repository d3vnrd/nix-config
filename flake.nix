{
  description = "A modular NixOs system built for the road";

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    supported = [
      "x86_64-linux"
    ];

    forAllSystems = let
      perSystemPkgs = lib.genAttrs supported (
        system:
          import nixpkgs {
            inherit system;
            overlays = [self.overlays.default];
          }
      );
    in
      f: lib.mapAttrs (_: f) perSystemPkgs;
  in {
    lib = import ./lib {inherit lib supported;};

    # Overlay, consumed by other flakes
    overlays = import ./overlays {inherit inputs lib;};

    # Used by `nix flake init -t <flake>`
    templates = import ./templates lib;

    # Nix-config's exposed modules
    nixosModules = self.lib.recursiveScan ./modules/nixos;
    darwinModules = self.lib.recursiveScan ./modules/darwin;
    homeModules = self.lib.recursiveScan ./modules/home;

    # For nix-config internal use only
    flakeModules = self.lib.recursiveScan ./modules/flake;

    # Executed by `nix flake check`
    checks = forAllSystems (pkgs: import ./checks {inherit inputs lib pkgs;});

    # Used by `nix develop .#<name>`
    devShells = forAllSystems (pkgs: import ./shells pkgs);

    # Set formatter used by `nix fmt`
    formatter = forAllSystems (pkgs: pkgs.nixfmt);

    # Exported package derivations
    packages = forAllSystems (pkgs:
      lib.packagesFromDirectoryRecursive {
        inherit (pkgs) callPackage;
        directory = ./pkgs;
      });
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
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
