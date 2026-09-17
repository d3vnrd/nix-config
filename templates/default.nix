lib: rec {
  default = nixos-init;

  nixos-init = {
    path = ./nixos;
    description = "Template to initialize new host";
  };

  nixos-iso = {
    path = ./iso;
    description = "Custom NixOs installer media generator";
  };
}
