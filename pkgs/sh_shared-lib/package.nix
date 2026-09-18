{pkgs}:
pkgs.stdenvNoCC.mkDerivation {
  name = "shared-lib";
  src = ./.;
  installPhase = ''
    mkdir -p $out
    cp *.sh $out/
  '';
}
