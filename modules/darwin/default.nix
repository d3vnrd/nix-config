{
  inputs,
  lib,
  ...
}: {
  imports = lib.flatten [
    ../.

    (lib.optional (inputs ? home-manager)
      inputs.home-manager.darwinModules.home-manager)

    (lib.optional (inputs ? sops-nix)
      inputs.sops-nix.darwinModules.sops)
  ];

  homebrew.enable = lib.mkDefault true;
  homebrew.onActivation.cleanup = "zap";
}
