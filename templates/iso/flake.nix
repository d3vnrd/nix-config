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
    nixosConfigurations = nix-config.lib.utils.mergeAttrsNoOverride (let
      inherit (nix-config.lib.maker) mkNixOsInstaller;
    in [
      (forAllSystems' (system: {
        name = "iso_${system}";
        value = mkNixOsInstaller {
          inherit inputs system;
          modules = [
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
        value = mkNixOsInstaller {
          inherit inputs system;
          modules = [
            nixos-wsl.nixosModules.wsl
            {
              wsl.enable = true;
              wsl.defaultUser = "nixos";
            }
          ];
        };
      }))
    ]);

    # Run `nix build <.#iso or .>` to generate iso-image
    packages = forAllSystems (system: rec {
      iso = self.nixosConfigurations."iso_${system}".config.system.build.isoImage;
      default = iso;
    });

    # Run `nix run <.#wsl or .>` to generate nixos.wsl installer
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
