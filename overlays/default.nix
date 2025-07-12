{
  outputs,
  inputs, # This 'inputs' argument holds the raw flake inputs
}: let
  addPatches = pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ patches;
    });
in rec {
  modifications = final: prev: {
    # currently none here 🎉
  };
}
