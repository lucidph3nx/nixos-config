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
    # use master for gemini-cli - things move quickly
    gemini-cli = inputs.nixpkgs-master.legacyPackages.${final.system}.gemini-cli;
    opencode = inputs.nixpkgs-master.legacyPackages.${final.system}.opencode;

    # user master for fluxcd, waiting for https://nixpk.gs/pr-tracker.html?pr=447904
    fluxcd = inputs.nixpkgs-master.legacyPackages.${final.system}.fluxcd;
  };
}
