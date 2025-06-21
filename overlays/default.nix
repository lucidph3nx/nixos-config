{
  outputs,
  inputs, # This 'inputs' argument holds the raw flake inputs
}: let
  addPatches = pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ patches;
    });
in {
  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs =
      builtins.mapAttrs
      (_: flake: (flake.legacyPackages or flake.packages or {}).${final.system} or {})
      inputs;
  };
  # Overlays for various pkgs (e.g. broken, not updated)
  modifications = final: prev: rec {
    # use master for mpd
    # waiting for https://nixpk.gs/pr-tracker.html?pr=418139
    # mpd = inputs.nixpkgs-master.legacyPackages.${final.system}.mpd;
    # use stable for qutebrowser
    # I think its this https://github.com/fedora-python/lxml_html_clean/issues/24
    # qutebrowser = inputs.nixpkgs-master.legacyPackages.${final.system}.qutebrowser;
  };
}
