{
  lib,
  ncLib,
  ...
}: let
  mkConfigurations = build: defaultModule: inputs: hosts: let
    inherit
      (ncLib.utils)
      mergeAttrsRecursive
      existingPathsRelativeTo
      ;

    normalize = value:
      if lib.isString value
      then {
        system = value;
        modules = [];
      }
      else {modules = [];} // value;
  in
    lib.mapAttrs (
      hostName: value: let
        host = normalize value;
      in
        build {
          inherit (host) system;
          specialArgs = {inherit inputs hostName;};

          modules = lib.flatten [
            {
              config._opts = mergeAttrsRecursive (map import (
                lib.flatten [
                  inputs.nix-config

                  # TODO: require testing to see if correctly override
                  (existingPathsRelativeTo inputs.self [
                    "default.nix"
                    "hosts/${hostName}/default.nix"
                  ])
                ]
              ));
            }

            defaultModule

            (existingPathsRelativeTo inputs.self [
              "hosts/${hostName}/configuration.nix"
              "hosts/${hostName}/hardware-configuration.nix"
            ])

            host.modules
          ];
        }
    )
    hosts;
in {
  # TODO: update templates to reflect new changes
  mkNixosConfigurations = inputs:
    mkConfigurations
    lib.nixosSystem
    inputs.nix-config.nixosModules.default
    inputs;

  mkDarwinConfigurations = inputs:
    mkConfigurations
    inputs.nix-darwin.lib.darwinSystem
    inputs.nix-config.darwinModules.default
    inputs;
}
