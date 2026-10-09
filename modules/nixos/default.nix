{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (config.default) user;
in {
  imports = lib.flatten [
    ../.

    (lib.optional (inputs ? home-manager)
      inputs.home-manager.nixosModules.home-manager)

    (lib.optional (inputs ? sops-nix)
      inputs.sops-nix.nixosModules.sops)

    (lib.optional (inputs ? nixos-wsl)
      inputs.nixos-wsl.nixosModules.wsl)
  ];

  config = {
    # TODO: understand how user can be set in nix and what's important
    users.mutableUsers = lib.mkDefault false;
    users.users.${user.name} = {
      inherit (user) description;
      isNormalUser = true;
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = user.sshAuthorizedKeys;
    };

    # TODO: should this be here should every host need ssh?
    services.openssh = {
      enable = true;
    };

    programs.vim = {
      enable = true;
      defaultEditor = lib.mkDefault true;
    };
  };
}
