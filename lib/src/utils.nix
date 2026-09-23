{lib, ...}: {
  existingPathsRelativeTo = root: paths:
    builtins.filter builtins.pathExists (map (p: root + "/${p}") paths);

  mergeAttrsNoOverride = builtins.foldl' lib.attrsets.unionOfDisjoint {};

  mergeAttrsRecursive = builtins.foldl' lib.recursiveUpdate {};
}
