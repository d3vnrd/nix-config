{
  inputs,
  lib,
  ...
}: {
  imports =
    [
      ../. # Global configs
      ./networking.nix
      ./locale.nix
    ]
    ++ lib.optional
    (inputs ? "home-manager")
    inputs.home-manager.nixosModules.home-manager;
}
