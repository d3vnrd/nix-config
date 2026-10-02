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
    sideloadInitLua = lib.mkDefault true;
    extraPackages = with pkgs; [
      fd
      fzf
      gcc
      tree-sitter
      xclip
      sqlite
    ];
  };

  xdg.configFile = let
    inherit (inputs) nix-config self;
  in
    nix-config.lib.utils.mergeAttrsNoOverride [
      {
        "nvim/init.lua" = let
          srcPath = "${self}/${vars.hostConfigDir}/nvim/init.lua";
        in {
          enable =
            builtins.pathExists srcPath
            && config.programs.neovim.sideloadInitLua;
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
          "nvim-pack-lock.json"
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
