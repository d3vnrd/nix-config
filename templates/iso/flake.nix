{
  description = "__DESCRIPTION__";

  outputs = {
    nixpkgs,
    disko,
    ...
  }: let
    inherit (nixpkgs) lib;

    supported = ["__SYSTEMS__"];
    modules = [
      disko.nixsoModules.disko
      ./configuration.nix
    ];
  in {
    nixosConfigurations = builtins.listToAttrs (
      map (system: {
        name = "iso-${system}";
        value = lib.nixosSystem {
          inherit system modules;
        };
      })
      supported
    );
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
