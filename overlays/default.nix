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

    # This version DOESN'T WORK!
    # vimPlugins = prev.vimPlugins // {
    #   obsidian-nvim = prev.vimUtils.buildVimPlugin {
    #     pname = "obsidian-nvim";
    #     version = "3.14.8";
    #     checkInputs = with prev.vimPlugins; [
    #       fzf-lua
    #       mini-nvim
    #       snacks-nvim
    #       telescope-nvim
    #     ];
    #     dependencies = with prev.vimPlugins; [
    #       plenary-nvim
    #     ];
    #     nvimSkipModules = [
    #       "minimal"
    #     ];
    #     src = prev.fetchFromGitHub {
    #       owner = "obsidian-nvim";
    #       repo = "obsidian.nvim";
    #       rev = "de60246baec087aaf5bbf95e3f976e0897548d89";
    #       hash = "sha256-jq/0GKn086/SDp3zw/yFBRuX8YpcYprUJLW98SNE63Y=";
    #     };
    #   };
    # };

    # There seems to be a bug in 3.14.8, cmp for References is not working.
    vimPlugins = prev.vimPlugins // {
      obsidian-nvim = prev.vimUtils.buildVimPlugin {
        pname = "obsidian-nvim";
        version = "3.14.7";
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
          rev = "6939efc2c7145cf83644192c588eccd935b57826";
          hash = "sha256-Gz5/DHNDVFy4tqWMyrmc3Rg7r1tGOx5330/B7r3OqiE=";
        };
      };
    };
  };
}
