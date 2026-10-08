{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  inherit (inputs) nix-config self;
in {
  imports = lib.flatten [
    (nix-config.lib.utils.existingPathsRelativeTo self [
      "home.nix"
    ])

    (lib.optional
      (inputs ? sops-nix)
      inputs.sops-nix.homeManagerModules.sops)
  ];

  options.M.dotfiles = {
    fetchFrom = lib.mkOption {
      description = ''
        Repositories to clone, as name = git URL, into defaultPath/<name>.
      '';
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        neovim = "https://github.com/example/neovim-config.git";
        emacs = "https://github.com/example/emacs-config.git";
      };
    };

    defaultPath = lib.mkOption {
      description = ''
        Default location where the dotfiles repository is cloned
        (must be outside ~/.config).
      '';
      type = lib.types.str;
      default = "${config.xdg.configHome}/dotfiles";
    };
  };

  config = lib.mkMerge [
    (
      let
        cfg = config.M.dotfiles;

        clone = name: url: ''
          if [ ! -d "${cfg.defaultPath}/${name}/.git" ]; then
            $DRY_RUN_CMD ${pkgs.git}/bin/git clone "${url}" "${cfg.defaultPath}/${name}" \
              || echo "fetchDotfiles: clone of ${url} failed, links into ${cfg.defaultPath}/${name} will dangle" >&2
          fi
        '';
      in {
        assertions =
          lib.mapAttrsToList (name: url: {
            assertion = url != "";
            message = "M.dotfiles.fetchFrom.${name}: URL must not be empty.";
          })
          cfg.fetchFrom;

        home.activation.fetchDotfiles = lib.mkIf (cfg.fetchFrom != {}) (
          lib.hm.dag.entryBefore ["writeBoundary"] ''
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList clone cfg.fetchFrom)}
          ''
        );
      }
    )

    (lib.optionalAttrs (inputs ? sops-nix) {
      sops.defaultSopsFile = lib.mkDefault "${inputs.self}/secrets.yaml";
      sops.age.keyFile = lib.mkDefault "${config.xdg.configHome}/sops/age/keys.txt";
    })
  ];
}
