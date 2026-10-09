{
  config,
  inputs,
  lib,
  ...
}: let
  inherit
    (inputs.nix-config.lib)
    mkNixosConfigurations
    mkDarwinConfigurations
    supported
    ;
  inherit (lib) mkOption types;
in {
  options.hosts = mkOption {
    description = "Hosts as name = {system; modules;}.";

    type = types.attrsOf (types.submodule ({config, ...}: {
      options = {
        system = mkOption {type = types.enum supported;};

        modules = mkOption {
          type = types.listOf types.raw;
          default = [];
        };

        isDarwin = mkOption {
          type = types.bool;
          readOnly = true;
          default = lib.hasSuffix "-darwin" config.system;
        };
      };
    }));

    default = {};
  };

  options.outputs = mkOption {
    type = types.lazyAttrsOf types.raw;
    internal = true;
    readOnly = true;
  };

  config.outputs = {
    nixosConfigurations = mkNixosConfigurations inputs (
      lib.filterAttrs (_: host: !host.isDarwin) config.hosts
    );

    darwinConfigurations = mkDarwinConfigurations inputs (
      lib.filterAttrs (_: host: host.isDarwin) config.hosts
    );

    # TODO: adding other host attrs examine flake-parts for example
  };
}
