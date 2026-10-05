{
  config,
  inputs,
  lib,
  pkgs,
  vars,
  ...
}: {
  imports = [./yazi.nix];

  programs.neovim = {
    enable = true;
    defaultEditor = lib.mkDefault true;
    sideloadInitLua = true;
    extraPackages = with pkgs; [
      fd
      fzf
      gcc
      tree-sitter
      xclip
      sqlite
    ];
  };

  home.packages = with pkgs; [
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
  ];

  xdg.configFile = let
    inherit (inputs) nix-config self;
  in
    nix-config.lib.utils.mergeAttrsNoOverride [
      {
        "nvim/init.lua" = let
          srcPath = "${self}/${vars.hostConfigDir}/nvim/init.lua";
        in {
          enable = lib.mkForce (
            (builtins.pathExists srcPath)
            && config.programs.neovim.sideloadInitLua
          );
          source = config.lib.file.mkOutOfStoreSymlink srcPath;
          force = true;
        };
      }

      (lib.optionalAttrs (inputs ? "neovim-config") (
        lib.genAttrs' [
          "lua"
          ".dprint.jsonc"
          ".luarc.jsonc"
          ".stylua.toml"

          # TODO: special case with neovim packages manager
          # "nvim-pack-lock.json"
        ] (name: {
          name = "nvim/${name}";
          value = {
            source = "${inputs.neovim-config}/${name}";
            force = true;
          };
        })
      ))
    ];
}
