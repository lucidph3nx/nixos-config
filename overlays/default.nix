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
    # I think its this https://github.com/NixOS/nixpkgs/issues/418689
    qutebrowser = inputs.nixpkgs-qutebrowserJune25.legacyPackages.${final.system}.qutebrowser;

    vimPlugins = (prev.vimPlugins or {}) // {
      # Access nixpkgs-stable directly from the 'inputs' argument to this overlay file
      # and then get its specific packages for the current system.
      obsidian-nvim = inputs.nixpkgs-stable.legacyPackages.${final.system}.vimPlugins.obsidian-nvim;
    };
    # use master branch for bindfs
    # while I wait for https://nixpk.gs/pr-tracker.html?pr=398248
    bindfs = inputs.nixpkgs-master.legacyPackages.${final.system}.bindfs;
  };
}
