{
  description = "__DESCRIPTION__";

  outputs = {
    nix-config,
    nixpkgs,
    ...
  } @ inputs: let
    system = "__SYSTEM__";
    hostname = "__HOSTNAME__";
  in {
    nixosConfigurations.${hostname} = nix-config.lib.mkHost {
      inherit inputs system hostname;
      build = nixpkgs.lib.nixosSystem;
      modules = with nix-config.nixosModules; [
        default
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
