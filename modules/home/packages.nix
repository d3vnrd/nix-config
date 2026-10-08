{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs; {
  home.packages = lib.flatten [
    (lib.optional (config.programs.neovim.enable) [
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

      # -- Formatter --
      dprint
      nixfmt
      ruff
      stylua
      typstyle
      shfmt
    ])
  ];
}
