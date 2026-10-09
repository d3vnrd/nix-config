{
  config,
  inputs,
  hostName,
  lib,
  pkgs,
  ...
}: let
  inherit
    (inputs.nix-config.lib.utils)
    mergeAttrsRecursive
    existingPathsRelativeTo
    ;
  inherit (lib) mkOption types;

  inherit (config.default) user;
in {
  options.default = mkOption {
    type = types.submodule {
      options.user = {
        name = mkOption {
          description = "Admin account name (not root).";
          type = types.strMatching "[a-z_][a-z0-9_-]*";
        };

        email = mkOption {
          description = "Email address, used for git. Empty means unset.";
          type = types.str;
        };

        description = mkOption {
          description = "Account description (GECOS).";
          type = types.str;
        };

        initialHashedPassword = mkOption {
          description = "Hashed password (a `$...` string from mkpasswd). Empty means no password is set.";
          type = types.strMatching "(\\$.+)?";
        };

        sshAuthorizedKeys = mkOption {
          description = "Public keys allowed to log in as the admin user.";
          type = types.listOf types.str;
        };
      };
    };

    internal = true;
    readOnly = true;
  };

  config.default = mergeAttrsRecursive (map import (
    [inputs.nix-config]
    ++ (existingPathsRelativeTo inputs.self [
      "default.nix"
      "hosts/${hostName}/default.nix"
    ])
  ));

  config.assertions = lib.flatten [
    {
      assertion = user.name != "root";
      message = ''
        default.user.name must not be root.
      '';
    }

    (lib.optional pkgs.stdenv.hostPlatform.isLinux {
      assertion = user.sshAuthorizedKeys != [] || user.initialHashedPassword != "";
      message = ''
        default.user needs an SSH key or a hashed password, or the host has no way in.
      '';
    })
  ];
}
