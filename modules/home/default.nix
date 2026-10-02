{
  config,
  inputs,
  lib,
  pkgs,
  vars,
  ...
}: {
  imports =
    lib.optional (inputs ? "sops-nix")
    inputs.sops-nix.homeManagerModules.sops;

  config = lib.mkMerge [
    {
      home.username = vars.username;

      home.packages = with pkgs; [
        # To disable default pkgs simply include lib.mkForce or lib.mkOverride
        # before pkgs list

        # -- LSP --
        bash-language-server
        lua-language-server
        yaml-language-server
        vscode-css-languageserver
        nil
        harper
        basedpyright
        tinymist
        markdown-oxide

        # -- DAP --

        # -- Linter --

        # -- Formatter --
        alejandra
        dprint
        nixfmt
        ruff
        stylua
        typstyle
        shfmt

        # -- Other --
        websocat # dependency for typst-preview
        ripgrep
        pandoc
      ];

      home.stateVersion = lib.mkDefault "26.05";
    }

    (lib.optionalAttrs (inputs ? "sops-nix") {
      sops.defaultSopsFile = lib.mkDefault "${inputs.self}/secrets.yaml";
      sops.age.keyFile = lib.mkDefault "${config.xdg.configHome}/sops/age/keys.txt";
      sops.age.generateKey = lib.mkDefault true;
    })
  ];
}
