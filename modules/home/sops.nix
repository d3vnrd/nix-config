{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  # TODO: adding assertions for checking inputs.sops-nix

  sops.defaultSopsFile = lib.mkDefault "${inputs.self}/secrets.yaml";
  sops.age.keyFile = lib.mkDefault "${config.xdg.configHome}/sops/age/keys.txt";
}
