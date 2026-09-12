{
  inputs,
  lib,
  ...
}: {
  imports = [
    ../. # Global configs
    ./networking.nix
    ./packages.nix

    (lib.optional
      (inputs ? "home-manager")
      inputs.home-manager.nixosModules.home-manager)
  ];
}
