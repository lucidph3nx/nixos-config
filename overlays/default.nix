{
  outputs,
  inputs,
}: let
  addPatches = pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ patches;
    });
in rec {
  modifications = final: prev: {
    # without this, darktable fails to build
    # fix is merged, waiting for https://nixpk.gs/pr-tracker.html?pr=424658
    darktable = inputs.nixpkgs-darktablejuly25.legacyPackages.${final.system}.darktable;
  };
}
