{
  pkgs,
  nix-config,
  ...
}:
pkgs.writeShellApplication rec {
  name = "remote-install";
  text = ''
    source "${nix-config.sh_shared-lib}/lib.sh"
    source "${./lib.sh}"
    ${builtins.readFile ./${name}.sh}
  '';
  runtimeInputs = with pkgs; [
    sops
    rsync
    git
    openssh
  ];
}
