pkgs: {
  default = pkgs.mkShell {
    packages = with pkgs; [
      nixfmt
      deadnix
    ];
    name = "nix-flake";
  };

  sops = pkgs.mkShell {
    packages = with pkgs; [
      sops
      age
      ssh-to-age
    ];
    name = "sops-nix";
  };
}
