{
  pkgs,
  nix-config,
  ...
}:
pkgs.writeShellApplication {
  name = "nixos-remote-install";
  text = builtins.readFile ./remote-install.sh;

  runtimeInputs = with pkgs; [
    sops
    rsync
    git
    openssh
  ];
  runtimeEnv = {
    LIB_PATH = "${nix-config.sh_shared-lib}";
  };
}
