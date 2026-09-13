{
  description = "__DESCRIPTION__";

  outputs = {
    self,
    nix-config,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    hostname = "__HOSTNAME__";
    system = "__SYSTEM__";

    vars = nix-config.util.mergeAttrsRecursive [
      (import nix-config)
      (import self)
    ];
  in {
    nixosConfigurations.${hostname} = lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs hostname vars;};
      modules = [
        nix-config.nixosModules.default
      ];
    };

    checks.${system} = nix-config.checks.${system};

    devShells.${system} = nix-config.devShells.${system};

    formatter.${system} = nix-config.formatter.${system};
  };

  inputs = {
    nix-config.url = "github:d3vnrd/nix-config";

    nixpkgs.follows = "nix-config/nixpkgs";
    home-manager.follows = "nix-config/home-manager";
  };
}
