{
  description = "__DESCRIPTION__";

  outputs = {
    self,
    nixpkgs,
    nix-config,
    nixos-wsl,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    supported = ["__SYSTEMS__"];

    forAllSystems = lib.genAttrs supported;
    forAllSystems' = lib.genAttrs' supported;
  in {
    nixosConfigurations = nix-config.lib.mergeAttrsNoOverride [
      (forAllSystems' (system: {
        name = "iso_${system}";
        value = nix-config.lib.mkInstaller {
          inherit inputs system;
          hostname = "iso";
          extraModules = [
            ({
              pkgs,
              modulesPath,
              ...
            }: {
              imports = [
                (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
              ];

              isoImage.squashfsCompression = "zstd -Xcompression-level 3";
              environment.systemPackages = [pkgs.disko];
            })
          ];
        };
      }))

      (forAllSystems' (system: {
        name = "wsl_${system}";
        value = nix-config.lib.mkInstaller {
          inherit inputs system;
          hostname = "wsl";
          extraModules = [
            {
              imports = [
                nixos-wsl.nixosModules.wsl
              ];

              wsl.enable = true;
              wsl.defaultUser = "nixos";
            }
          ];
        };
      }))
    ];

    packages = forAllSystems (system: rec {
      iso = self.nixosConfigurations."iso_${system}".config.system.build.isoImage;
      default = iso;
    });

    apps = forAllSystems (system: rec {
      wsl = {
        type = "app";
        program =
          lib.getExe
          self.nixosConfigurations."wsl_${system}".config.system.build.tarballBuilder;
      };
      default = wsl;
    });
  };

  inputs = {
    nix-config.url = "github:d3vnrd/nix-config";
    nixpkgs.follows = "nix-config/nixpkgs";
    nixos-wsl.follows = "nix-config/nixos-wsl";
  };
}
