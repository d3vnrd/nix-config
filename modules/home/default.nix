{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nix-config self;
in {
  imports = lib.flatten [
    (nix-config.lib.utils.existingPathsRelativeTo self ["home.nix"])
    (lib.optional (inputs ? "sops-nix") ./sops.nix)
  ];

  options.nixConfig = {
    dotfiles.path = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/dotfiles";
      description = "Default location where the dotfiles repository is cloned.";
    };

    dotfiles.fetchFrom = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Dotfiles repositories to clone, as name = git URL. Each is cloned to path/<name>.";
      example = {
        neovim = "https://github.com/example/neovim-config.git";
        emacs = "https://github.com/example/emacs-config.git";
      };
    };
  };
}
