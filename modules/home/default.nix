{
  osConfig ?
    throw ''
      nix-config's Home Manager modules only support the integrated mode
      (home-manager.nixosModules or home-manager.darwinModules).
      Standalone `home-manager switch` is not supported: these modules read
      `osConfig` for the hostname and the user, which only exists there.
    '',
  config,
  inputs,
  lib,
  ...
}: let
  inherit (inputs) nix-config self;
in {
  imports = lib.flatten [
    (nix-config.lib.utils.existingPathsRelativeTo self [
      "hosts/${osConfig.networking.hostName}/home.nix"
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
      '';
      type = lib.types.str;
      default = "${config.xdg.configHome}/dotfiles";
    };
  };

  config = lib.mkMerge [
    {
      assertions =
        lib.mapAttrsToList (name: url: {
          assertion = url != "";
          message = "M.dotfiles.fetchFrom.${name}: URL must not be empty.";
        })
        config.M.dotfiles.fetchFrom;

      home.stateVersion = lib.mkDefault "26.05";
    }

    (lib.optionalAttrs (inputs ? sops-nix) {
      sops.defaultSopsFile = lib.mkDefault "${inputs.self}/secrets.yaml";
      sops.age.keyFile = lib.mkDefault "${config.xdg.configHome}/sops/age/keys.txt";
    })
  ];
}
