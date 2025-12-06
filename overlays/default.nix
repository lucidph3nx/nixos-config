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

    vimPlugins = prev.vimPlugins // {
      obsidian-nvim = prev.vimUtils.buildVimPlugin {
        pname = "obsidian-nvim";
        version = "2025-11-24";
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
          rev = "4065c233f618cdbfbf084d87e97317f8d019ef59";
          hash = "sha256-hG1Dji1Xrl7yLLB5nN7twCuldIZt6GYWwJJaYCcGTqc=";
        };
      };
    };
  };
}
