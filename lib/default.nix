lib: rec {
  recursiveScan = {
    path,
    func ? (p: p),
  }: let
    entries =
      lib.filterAttrs (
        name: type:
          type
          == "directory"
          || (type == "regular" && lib.hasSuffix ".nix" name)
      )
      (builtins.readDir path);
  in
    lib.mapAttrs' ( # Prime version allows changes to attr names
      name: type: {
        name = lib.removeSuffix ".nix" name;
        value =
          if type == "directory"
          then
            recursiveScan {
              path = path + "/${name}";
              inherit func;
            }
          else func (path + "/${name}");
      }
    )
    entries;

  optionalPaths = paths:
    builtins.filter (
      path: path != null && builtins.pathExists path
    )
    paths;

  mkHost = {
    build,
    inputs,
    system,
    hostname ? "nixos",
    modules ? [],
  }:
    build {
      inherit system modules;
      specialArgs = {
        inherit inputs hostname;
        vars = mergeAttrsRecursive (builtins.map import (
          [../.] ++ optionalPaths [(inputs.self + "/default.nix")]
        ));
      };
    };

  mergeAttrsNoOverride = builtins.foldl' lib.attrsets.unionOfDisjoint {};

  mergeAttrsRecursive = builtins.foldl' lib.recursiveUpdate {};
}
