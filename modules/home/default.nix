{
  config,
  inputs,
  lib,
  pkgs,
  vars,
  ...
}: let
  cfg = config.M;
in {
  imports =
    lib.optional (inputs ? "sops-nix") inputs.sops-nix.homeManagerModules.sops;

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
        default = "${config.xdg.configHome}/dotfiles";
        description = "Location where the dotfiles repository is cloned.";
      };
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
