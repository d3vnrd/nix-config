{
  config,
  lib,
  pkgs,
  vars,
  ...
}: let
  cfg = config.M;
in {
  options.M = {
    dotfiles = {
      enable = lib.mkEnableOption "Enable support for user dotfiles.";

      url = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Git repository containing the user's dotfiles.";
        example = "https://github.com/example/dotfiles.git";
      };

      path = lib.mkOption {
        type = lib.types.str;
        default = "${config.home.homeDirectory}/dotfiles";
        description = "Location where the dotfiles repository is cloned.";
      };
    };

    enableDefaultPkgs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable default user packages.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.dotfiles.enable {
      # https://nixos.org/manual/nixos/stable/#sec-assertions-assetions
      assertions = [
        {
          assertion = cfg.dotfiles.url != "";
          message = "A dotfiles URL is required.";
        }
      ];

      # https://www.foodogsquared.one/posts/2023-03-24-managing-mutable-files-in-nixos/
      home.activation.fetchDotfiles = lib.hm.dag.entryBefore ["writeBoundary"] ''
        if [ ! -d "${cfg.dotfiles.path}/.git" ]; then
          ${pkgs.git}/bin/git clone \
            "${cfg.dotfiles.url}" \
            "${cfg.dotfiles.path}"
        fi
      '';
    })

    {
      home.username = vars.username;

      home.packages = lib.optionals cfg.enableDefaultPkgs (with pkgs; [
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

      home.stateVersion = lib.mkDefault "26.05";
    }
  ];
}
