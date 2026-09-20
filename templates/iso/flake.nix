{
  description = "__DESCRIPTION__";

  outputs = {
    self,
    nixpkgs,
    nixos-wsl,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    supported = ["__SYSTEMS__"];

    mkInstaller = name: extraModules:
      lib.genAttrs' supported (
        system: {
          name = "${name}_${system}";
          value = lib.nixosSystem {
            inherit system;
            specialArgs = {inherit inputs system;};
            modules =
              [
                ({pkgs, ...}: {
                  nix.settings.experimental-features = ["nix-command" "flakes"];
                  nixpkgs.config.allowUnfree = true;

                  networking.hostName = name;

                  programs.git.enable = true;
                  programs.vim = {
                    enable = true;
                    defaultEditor = true;
                  };
                })
              ]
              ++ extraModules;
          };
        }
      );
  in {
    nixosConfigurations =
      (mkInstaller "iso" [
        ({
          inputs,
          pkgs,
          modulesPath,
          system,
          ...
        }: {
          imports = [
            (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
          ];

          isoImage.squashfsCompression = "zstd -Xcompression-level 3";

          environment.systemPackages = with pkgs; [disko];
        })
      ])
      ++ (mkInstaller "wsl" [
        {
          imports = [
            nixos-wsl.nixosModules.wsl
          ];

          wsl.enable = true;
          wsl.defaultUser = "nixos";
        }
      ]);

    packages = lib.genAttrs supported (system: {
      default =
        self.nixosConfigurations."iso_${system}".config.system.build.isoImage;
      wsl =
        self.nixosConfigurations."wsl_${system}".config.system.build.tarballBuilder;
    });
  };

  inputs = {
    nix-config.url = "github:d3vnrd/nix-config";
    nixpkgs.follows = "nix-config/nixpkgs";
    nixos-wsl.follows = "nix-config/nixos-wsl";
  };
}
