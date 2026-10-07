{
  description = "__DESCRIPTION__";

  outputs = {nix-config, ...} @ inputs:
    nix-config.lib.mkHostsFlake inputs {
      hosts = {
        __HOSTNAME__ = {
          system = "__SYSTEM__";
          modules = [];
        };
      };

      checks = pkgs: {};
      devShells = pkgs: {};
    };

  inputs = {
    nix-config.url = "github:d3vnrd/nix-config";

    nixpkgs.follows = "nix-config/nixpkgs";
    home-manager.follows = "nix-config/home-manager";
  };
}
