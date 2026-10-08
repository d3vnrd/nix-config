{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (config.M) dotfiles;
  mutable = dotfiles.fetchFrom ? neovim;
in {
  config = lib.mkMerge [
    {
      programs.neovim = {
        enable = true;
        defaultEditor = lib.mkDefault true;
        extraPackages = with pkgs; [fd fzf xclip sqlite];
      };
    }

    (lib.mkIf mutable (let
      url = dotfiles.fetchFrom.neovim;
      path = "${dotfiles.defaultPath}/nvim";
    in {
      home.activation.fetchNvimConfig = lib.hm.dag.entryBefore ["writeBoundary"] ''
        if [ ! -d "${path}/.git" ]; then
          $DRY_RUN_CMD ${pkgs.git}/bin/git clone "${url}" "${path}" \
            || echo "fetchNvimConfig: clone of ${url} failed, ~/.config/nvim will dangle" >&2
        fi
      '';

      programs.neovim = {
        sideloadInitLua = true;
        extraPackages = with pkgs; [gcc tree-sitter curl gnutar];
      };

      xdg.configFile."nvim".source =
        config.lib.file.mkOutOfStoreSymlink path;
    }))

    (lib.mkIf (!mutable) {
      programs.neovim = {
        sideloadInitLua = false;
        initLua = builtins.readFile "${inputs.nix-config}/.config/nvim/init.lua";
        plugins = [
          (pkgs.vimPlugins.nvim-treesitter.withPlugins (p:
            with p; [
              bash
              json
              lua
              markdown
              markdown_inline
              nix
              python
            ]))
        ];
      };
    })
  ];
}
