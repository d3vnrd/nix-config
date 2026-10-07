{lib}: let
  mkConfigurations = {
    inputs,
    build,
    defaultModule,
  }: hosts:
    lib.mapAttrs (
      hostName: host:
        build {
          inherit (host) system;

          specialArgs = {inherit inputs hostName;};

          modules = lib.flatten [
            (import ./_internal/global-opts.nix lib)

            defaultModule

            (lib.ext.utils.existingPathsRelativeTo inputs.self [
              "hosts/${hostName}/configuration.nix"
              "hosts/${hostName}/hardware-configuration.nix"
            ])

            (host.modules or [])
          ];
        }
    )
    hosts;

  errorExample = ''
    For example:

        outputs = inputs@{ nix-config, ... }:
          nix-config.lib.mkHostsFlake { inherit inputs; } { /* module */ };

    Pass the output function arguments as `inputs`. Do not pass
    `self.inputs`, since `inputs` must include `self`.
  '';
in {
  mkNixosConfigurations = inputs:
    mkConfigurations {
      inherit inputs;
      build = inputs.nixpkgs.lib.nixosSystem;
      defaultModule = inputs.nix-config.nixosModules.default;
    };

  mkDarwinConfigurations = inputs:
    mkConfigurations {
      inherit inputs;
      build =
        lib.throwIf (!inputs ? nix-darwin) ''
          mkDarwinConfigurations: forgot to add nix-darwin in inputs?
        ''
        inputs.nix-darwin.lib.darwinSystem;
      defaultModule = inputs.nix-config.darwinModules.default;
    };

  mkHostsFlake = {inputs}: module: let
    eval = lib.evalModules {
      specialArgs = {inherit inputs;};
      modules = [
        (import ./_internal/hosts-flake.nix lib)
        module
      ];
    };
  in
    lib.throwIf (!inputs ? self) ''
      mkHostsFlake: `inputs` must include `self`.

      Please pass the output function arguments. ${errorExample}
    ''
    eval.config.outputs;
}
