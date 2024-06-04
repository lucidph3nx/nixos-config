{
  outputs,
  inputs,
}: let
  addPatches = pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ patches;
    });
in {
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs =
      builtins.mapAttrs
      (_: flake: (flake.legacyPackages or flake.packages or {}).${final.system} or {})
      inputs;
  };
  # Overlays for various pkgs (e.g. broken, not updated)
  modifications = final: prev: rec {
    openrazer-daemon = prev.openrazer-daemon.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.pkgs.gobject-introspection final.pkgs.wrapGAppsHook3 final.pkgs.python3Packages.wrapPython];
    });
  };
}
