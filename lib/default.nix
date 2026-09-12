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

  mergeAttrsNoOverride = builtins.foldl' lib.attrsets.unionOfDisjoint {};

  optionalPath = path: lib.optional (path != null && builtins.pathExists path) path;
}
