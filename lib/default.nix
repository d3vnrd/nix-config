{
  lib,
  supported ? [],
}: let
  recursiveScan = path:
    lib.foldlAttrs (
      acc: entry: type: let
        key = lib.toCamelCase (lib.removeSuffix ".nix" entry);
        curr = lib.path.append path entry;
        value =
          if type == "directory"
          then recursiveScan curr
          else curr;
      in
        if acc ? ${key}
        then
          throw
          "recursiveScan contains name collision in ${toString path}: ${key}"
        else acc // {${key} = value;}
    ) {} (lib.filterAttrs (
      name: type:
        !(builtins.any (prefix: lib.hasPrefix prefix name) ["_" "."])
        && (type == "directory" || (type == "regular" && lib.hasSuffix ".nix" name))
    ) (builtins.readDir path));
in
  lib.fix (
    ext: let
      inherit
        (lib.attrsets)
        genAttrs
        unionOfDisjoint
        mapAttrsRecursive
        ;

      callLibs = file:
        import file {
          lib = lib.extend (final: prev: {inherit ext;});
        };
    in
      unionOfDisjoint (mapAttrsRecursive (_: callLibs) (recursiveScan ./src)) {
        inherit recursiveScan;
        inherit (ext.flake) mkHostsFlake;

        supported = genAttrs supported (name: name);
      }
  )
