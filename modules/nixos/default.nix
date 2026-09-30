{
  inputs,
  lib,
  ...
}: {
  imports = lib.flatten [
    ../.

    # TODO: replace the per-input `lib.optional` calls
    (lib.optional (inputs ? "home-manager")
      inputs.home-manager.nixosModules.home-manager)

    (lib.optional (inputs ? "sops-nix")
      inputs.sops-nix.nixosModules.sops)

    (lib.optional (inputs ? "nixos-wsl")
      inputs.nixos-wsl.nixosModules.wsl)
  ];
}
