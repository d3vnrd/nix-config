#TODO: need better errors handling
lib: rec {
  recursiveScan = path:
  /*
   Recursively scan a directory into a nested attribute set of paths.

   Each `.nix` file becomes an attribute named after the file without its
   suffix, with the file's path as the value. Each subdirectory becomes a
   nested attribute set built by the same rule. Other entries (non-Nix files,
   symlinks) are ignored. No files are imported; the result is only a tree
   of paths, so apply `lib.mapAttrsRecursive (_: import)` (or any other
   function) to the leaves separately.

   Throws if a directory holds two entries that map to the same name, such
   as `foo.nix` next to `foo/`.

   # Examples
   Given `module/a.nix`, `module/b/c.nix` and `module/b/d.nix`, `recursiveScan'
   ./module` returns:

   ```nix
   result = {
     a = ./module/a.nix;
     b = {
       c = ./module/b/c.nix;
       d = ./module/b/d.nix;
     };
   };
  ```
  */
    lib.foldlAttrs ( # This one is with an `l` not the 'foldAttrs'
      acc: name: type: let
        key = lib.removeSuffix ".nix" name;
        curr = path + "/${name}";
      in
        if acc ? ${key}
        then throw "recursiveScan: name collision in ${toString path}: ${key}"
        else
          acc
          // {
            ${key} =
              if type == "directory"
              then recursiveScan curr
              else curr;
          }
    ) {} (lib.filterAttrs (
      name: type:
        type == "directory" || (type == "regular" && lib.hasSuffix ".nix" name)
    ) (builtins.readDir path));

  optionalPaths = paths:
    builtins.filter (path: path != null && builtins.pathExists path) paths;

  existingPathsRelativeTo = pos: paths:
    builtins.filter builtins.pathExists (
      map (p: pos + "/${p}") paths
    );

  mergeAttrsNoOverride = builtins.foldl' lib.attrsets.unionOfDisjoint {};

  mergeAttrsRecursive = builtins.foldl' lib.recursiveUpdate {};

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
          [../.] ++ (existingPathsRelativeTo inputs.self ["default.nix"])
        ));
      };
    };

  mkInstaller = {
    inputs,
    system,
    hostname,
    extraModules ? [],
  }:
    mkHost {
      inherit inputs system hostname;
      build = lib.nixosSystem;
      modules =
        [inputs.nix-config.nixosModules.default]
        ++ extraModules;
    };
}
