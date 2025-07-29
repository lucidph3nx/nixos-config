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
    vimPlugins =
      prev.vimPlugins
      // {
        # waiting for this fix to end up in nixpkgs
        # https://github.com/obsidian-nvim/obsidian.nvim/pull/281
        obsidian-nvim = prev.vimUtils.buildVimPlugin {
          pname = "obsidian-nvim";
          version = "2025-07-11";
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
            rev = "3fbe2a8b0a2170565bba521feaecd22e67fe3600";
            hash = "sha256-dDTDJAO3eGEWGu5JfxWLOgaQcZPmw+AYgHzv1XIWze8=";
          };
        };
      };
  };
}
