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
    # new issues https://github.com/NixOS/nixpkgs/issues/429268
    # it seems like libsoup is used by osm-gps-map which is used by darktable
    # and we are all mad at libsoup 2, because its unmaintained and riddled with security issues
    darktable = inputs.nixpkgs-darktablejuly25.legacyPackages.${final.system}.darktable;

    # waiting for https://nixpk.gs/pr-tracker.html?pr=429146
    ncmpcpp = inputs.nixpkgs-master.legacyPackages.${final.system}.ncmpcpp;
  };
}
