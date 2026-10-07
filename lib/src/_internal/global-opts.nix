lib: {
  inputs,
  hostName,
  ...
}: let
  inherit (lib.ext.utils) mergeAttrsRecursive existingPathsRelativeTo;
in {
  # TODO: update adding submodule options for _opts
  options._opts = lib.mkOption {};

  config._opts = mergeAttrsRecursive (map import (
    [inputs.nix-config]
    ++ (existingPathsRelativeTo inputs.self [
      "default.nix"
      "hosts/${hostName}/default.nix"
    ])
  ));
}
