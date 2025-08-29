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
    # without this, darktable fails to build
    # fix is merged, waiting for https://nixpk.gs/pr-tracker.html?pr=424658
    # new issues https://github.com/NixOS/nixpkgs/issues/429268
    # it seems like libsoup is used by osm-gps-map which is used by darktable
    # and we are all mad at libsoup 2, because its unmaintained and riddled with security issues
    darktable = inputs.nixpkgs-darktablejuly25.legacyPackages.${final.system}.darktable;

    vimPlugins = prev.vimPlugins // {
      # waiting for this fix to end up in nixpkgs
      # https://github.com/obsidian-nvim/obsidian.nvim/commit/7198ba7b9d18d16eaa5c9ccd05ba073668656499
      obsidian-nvim = prev.vimUtils.buildVimPlugin {
        pname = "obsidian-nvim";
        version = "2025-08-22";
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
          rev = "e7818ca1f469dc90a3d7aef886531da11ffbe254";
          hash = "sha256-6qFv/mhKsNgvGSBmoWevqFnt2e6DakCYs6t13M+r+3k=";
        };
      };
    };
    # use master for gemini-cli - things move quickly
    gemini-cli = inputs.nixpkgs-master.legacyPackages.${final.system}.gemini-cli;
    opencode = inputs.nixpkgs-master.legacyPackages.${final.system}.opencode;
  };
}
