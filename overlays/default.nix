{
  inputs,
  lib,
}: {
  default = final: prev: {
    nix-config = prev.lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ../pkgs;
    };
  };
}
