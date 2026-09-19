{
  config,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [gcc tree-sitter fd];
  };

  home.file.".config/nvim" = {
    source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.M.dotfiles.path}/nvim";

    enable = config.M.dotfiles.enable;
  };
}
