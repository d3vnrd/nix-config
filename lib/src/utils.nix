{lib, ...}: rec {
  existingPaths = paths:
    builtins.filter (p: builtins.pathExists p) paths;

  existingPathsRelativeTo = root: paths:
    existingPaths (map (p: root + "/${p}") paths);

  mergeAttrsNoOverride = builtins.foldl' lib.attrsets.unionOfDisjoint {};

  mergeAttrsRecursive = builtins.foldl' lib.recursiveUpdate {};
}
