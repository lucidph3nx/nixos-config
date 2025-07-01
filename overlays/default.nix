{
  outputs,
  inputs, # This 'inputs' argument holds the raw flake inputs
}: 
let
  addPatches = pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ patches;
    });
in
rec {
  modifications = final: prev: {
    vimPlugins = (prev.vimPlugins or {}) // {
      # Access nixpkgs-stable directly from the 'inputs' argument to this overlay file
      # and then get its specific packages for the current system.
      obsidian-nvim = inputs.nixpkgs-stable.legacyPackages.${final.system}.vimPlugins.obsidian-nvim;
    };
  };
}
