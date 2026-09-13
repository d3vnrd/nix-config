{
  inputs,
  lib,
  ...
}: {
  imports = [
    ../. # Global configs
    ./networking.nix
    ./packages.nix
    ./locale.nix

    (lib.optional
      (inputs ? "home-manager")
      inputs.home-manager.nixosModules.home-manager)
  ];
}
