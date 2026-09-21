{
  inputs,
  lib,
  ...
}: {
  imports =
    [../.]
    ++ (
      lib.optional
      (inputs ? "home-manager")
      inputs.home-manager.nixosModules.home-manager
    );
}
