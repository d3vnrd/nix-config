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
    nixosConfigurations.${hostname} = nix-config.lib.mkNixOsSystem {
      inherit inputs system hostname;
      modules = with nix-config.nixosModules; [
        # Import nix-config modules here
        locale
        networking
        packages
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
