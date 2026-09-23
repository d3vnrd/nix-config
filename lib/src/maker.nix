{
  lib,
  ncLib,
  ...
}: let
  inherit
    (ncLib.utils)
    mergeAttrsRecursive
    existingPathsRelativeTo
    ;
in rec {
  mkHost = {
    build,
    inputs,
    system,
    hostname,
    modules ? [],
  }:
    build {
      inherit system modules;
      specialArgs = {
        inherit inputs hostname;
        vars = mergeAttrsRecursive (map import (
          [inputs.nix-config]
          ++ (existingPathsRelativeTo inputs.self ["default.nix"])
        ));
      };
    };

  mkNixOsInstaller = {
    inputs,
    system ? "x86_64-linux",
    modules ? [],
  }:
    mkHost {
      inherit inputs system;
      build = lib.nixosSystem;
      hostname = "nixos";
      modules = modules ++ [inputs.nix-config.nixosModules.default];
    };

  mkNixOsSystem = {
    inputs,
    system ? "x86_64-linux",
    hostname ? "nixos",
    modules ? [],
  }:
    mkHost {
      inherit inputs system hostname;
      build = lib.nixosSystem;
      modules = modules ++ [inputs.nix-config.nixosModules.default];
    };

  mkDarwinSystem = {
    inputs,
    hostname ? "darwin",
    modules ? [],
  }:
    mkHost {
      inherit inputs hostname;
      build = inputs.nix-darwin.lib.darwinSystem;
      system = "aarch64-darwin"; # x86_64-darwin (Intel) is being deprecated
      modules = modules ++ [inputs.nix-config.darwinModules.default];
    };
}
