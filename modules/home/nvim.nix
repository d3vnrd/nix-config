{
  config,
  pkgs,
  ...
}: let
  cfg = config.M;
in {
  imports = [
    ./yazi.nix
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    sideloadInitLua = cfg.dotfiles.enable;
    extraPackages = with pkgs; [
      fd
      fzf
      gcc
      tree-sitter
      xclip
      sqlite
    ];
  };

  home.file.".config/nvim" = {
    source =
      config.lib.file.mkOutOfStoreSymlink
      "${cfg.dotfiles.path}/nvim";

    enable = cfg.dotfiles.enable;
  };
}
