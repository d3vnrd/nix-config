lib: {
  config,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (lib.ext.flake) mkNixosConfigurations mkDarwinConfigurations;
in {
  options.hosts = mkOption {
    description = "Hosts as name = {system; modules;}.";

    type = types.attrsOf (types.submodule ({config, ...}: {
      options = {
        # TODO: add custom type check for valid system str
        system = mkOption {type = types.str;};

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
  };
}
