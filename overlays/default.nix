{
  outputs,
  inputs,
}:
let
  addPatches =
    pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ patches;
    });
in
rec {
  modifications = final: prev: {
    # use stable for firefox, unstable is currently failing to build
    firefox = inputs.nixpkgs-stable.legacyPackages.${final.stdenv.hostPlatform.system}.firefox;

    # use master for opencode, need the bleeding edge
    opencode = inputs.nixpkgs-master.legacyPackages.${final.stdenv.hostPlatform.system}.opencode;
  };
}
