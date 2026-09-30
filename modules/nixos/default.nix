{
  inputs,
  lib,
  ...
}: {
  imports = lib.flatten [
    ../.

    (lib.optional (inputs ? "home-manager")
      inputs.home-manager.nixosModules.home-manager)

    (lib.optional (inputs ? "sops-nix")
      inputs.sops-nix.nixosModules.sops)
  ];
}
