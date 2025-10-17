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
    # use master for opencode, need the bleeding edge
    opencode = inputs.nixpkgs-master.legacyPackages.${final.system}.opencode;

    # use older nixpkgs for calibre to avoid hipblaslt memory issues during build
    calibre = inputs.nixpkgs-calibre-fix.legacyPackages.${final.system}.calibre;

    vimPlugins =
      prev.vimPlugins
      // {
        # There is a fix for this issue, but its aparently not in unstable yet
        # https://github.com/obsidian-nvim/obsidian.nvim/issues/387
        obsidian-nvim = prev.vimUtils.buildVimPlugin {
          pname = "obsidian-nvim";
          version = "2025-10-09";
          checkInputs = with prev.vimPlugins; [
            fzf-lua
            mini-nvim
            snacks-nvim
            telescope-nvim
          ];
          dependencies = with prev.vimPlugins; [
            plenary-nvim
          ];
          nvimSkipModules = [
            "minimal"
          ];
          src = prev.fetchFromGitHub {
            owner = "obsidian-nvim";
            repo = "obsidian.nvim";
            rev = "a1d2617a5d1db4b8c53a3431943168e7a28a38d7";
            hash = "sha256-6uYT4Eyi+nGRzC7YUEwM5ScbVf6MnN+PghNq8ugzSCU=";
          };
        };
      };
  };
}
