{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    nx.programs.python.enable = lib.mkEnableOption "enables python env" // {
      default = true;
    };
  };
  config = lib.mkIf config.nx.programs.python.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        (python3.withPackages (python313Packages: [
          python313Packages.requests
          (python313Packages.buildPythonPackage rec {
            pname = "specify-cli";
            version = "unstable-2024-10-03";
            pyproject = true;
            src = fetchFromGitHub {
              owner = "github";
              repo = "spec-kit";
              rev = "main";
              sha256 = "sha256-iPYro9Uje9L2me8HBgNVo+bloNk6LSzB0tIoQzzZ+d4=";
            };
            build-system = with python313Packages; [
              hatchling
            ];
            propagatedBuildInputs = with python313Packages; [
              httpx
              platformdirs
              readchar
              rich
              truststore
              typer
            ];
            doCheck = false;
          })
        ]))
      ];
    };
  };
}
