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
  modifications =
    final: prev:
    let
      # Import nixpkgs-master with unfree packages allowed
      masterPkgs = import inputs.nixpkgs-master {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    in
    {
      # use stable for firefox, unstable is currently failing to build
      firefox = inputs.nixpkgs-stable.legacyPackages.${final.stdenv.hostPlatform.system}.firefox;

      # use master for opencode, need the bleeding edge
      opencode = masterPkgs.opencode;

      # use master for claude-code, need the bleeding edge
      claude-code = masterPkgs.claude-code;

      vimPlugins = prev.vimPlugins // {
        obsidian-nvim = prev.vimUtils.buildVimPlugin {
          pname = "obsidian-nvim";
          version = "3.15.3";
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
            rev = "cc9f7b2588577a1961c563b8baa90f636e2d61b7";
            hash = "sha256-tGS1QLNcArFGGj2g2cmguHwzlEQBSRiCzj0FLxbm1FQ=";
          };
        };
      };
    };
}
