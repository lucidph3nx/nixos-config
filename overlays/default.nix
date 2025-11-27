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
    calibre = inputs.nixpkgs-stable.legacyPackages.${final.system}.calibre;

    vimPlugins = prev.vimPlugins // {
      # There is a fix for this issue, but its aparently not in unstable yet
      # https://github.com/obsidian-nvim/obsidian.nvim/issues/387
      obsidian-nvim = prev.vimUtils.buildVimPlugin {
        pname = "obsidian-nvim";
        version = "2025-11-06";
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
          rev = "01cde93f6705e7f20c14857a30f5f5bf6140f808";
          hash = "sha256-hG1Dji1Xrl7yLLB5nN7twCuldIZt6GYWwJJaYCcGTqc=";
        };
      };
      # broken on 2025-11-28, supposedly fixed in https://github.com/NixOS/nixpkgs/pull/464616
      # however, that should be merged and in unstable but its still an issue
      lualine-nvim = prev.neovimUtils.buildNeovimPlugin {
        luaAttr = prev.luaPackages.lualine-nvim.overrideAttrs {
          knownRockspec =
            (prev.fetchurl {
              url = "mirror://luarocks/lualine.nvim-scm-1.rockspec";
              sha256 = "01cqa4nvpq0z4230szwbcwqb0kd8cz2dycrd764r0z5c6vivgfzs";
            }).outPath;
          src = prev.fetchFromGitHub {
            owner = "nvim-lualine";
            repo = "lualine.nvim";
            rev = "47f91c416daef12db467145e16bed5bbfe00add8";
            hash = "sha256-OpLZH+sL5cj2rcP5/T+jDOnuxd1QWLHCt2RzloffZOA=";
          };
        };
      };
    };
  };
}
