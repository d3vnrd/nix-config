{
  config,
  lib,
  pkgs,
  ...
}: {
  options.M.enableDefaultPkgs = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable default user packages.";
  };

  home.packages = lib.optionals config.M.enableDefaultPkgs (with pkgs; [
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
  ]);
}
