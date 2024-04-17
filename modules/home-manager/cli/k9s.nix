{ config, pkgs, inputs, lib, ... }: 

let
  terminal = config.sysDefaults.terminal;
in
{
  options = {
    homeManagerModules.k9s.enable =
      lib.mkEnableOption "enables k9s";
  };
  config = lib.mkIf config.homeManagerModules.k9s.enable {
    programs.k9s = {
      enable = true;
      package = pkgs.k9s;
      settings = {
        k9s = {
          liveViewAutoRefresh = false;
          refreshRate = 2;
          maxConnRetry = 5;
          readOnly = false;
          noExitOnCtrlC = true;
          ui = {
            enableMouse = false;
            headless = true; 
            logoless = false;
            crumbsless = false;
            reactive = false;
            noIcons = false;
          };
          skipLatestRevCheck = false;
          disablePodCounting = false;
          shellPod= {
            image = "busybox:1.35.0";
            namespace = "default";
            limits = {
              cpu = "100m";
              memory = "100Mi";
            };
          };
          imageScans = {
            enable = false;
          };
          logger = {
            tail = 100;
            buffer = 5000;
            sinceSeconds = -1;
            fullScreen = false;
            textWrap = false;
            showTime = false;
          };
          thresholds = {
            cpu = {
              critical = 90;
              warn = 70;
            };
            memory = {
              critical = 90;
              warn = 70;
            };
          };
        };
      };
      aliases = {
        cr = "clusterroles";
        crb = "clusterrolebindings";
        dp = "deployments";
        hr = "HelmRelease";
        jo = "jobs";
        ks = "kustomizations";
        np = "networkpolicies";
        rb = "rolebindings";
        ro = "roles";
        sec = "v1/secrets";
      };
      views = {
        "v1/pods" = {
          columns = [
          "AGE"
          "NAMESPACE"
          "NAME"
          "PF"
          "READY"
          "RESTARTS"
          "STATUS"
          "%CPU/L"
          "%MEM/L"
          "NODE"
          ];
        };
        "v1/nodes" = {
          columns = [
            "AGE"
            "NAME"
            "STATUS"
            "ROLE"
            "VERSION"
            "PODS"
            "INTERNAL-IP"
          ];
        };
      };
      skin = with config.theme; {
        k9s = {
          body = {
            fgColor = "${foreground}";
            bgColor = "${bg0}";
            logoColor = "${green}";
          };
          prompt = {
            fgColor = "${foreground}";
            bgColor = "${bg0}";
            suggestColor = "${orange}";
          };
          info = {
            fgColor = "${grey1}";
            sectionColor = "${green}";
          };
          dialog = {
            fgColor = "${foreground}";
            bgColor = "${bg0}";
            buttonFgColor = "${foreground}";
            buttonBgColor = "${green}";
            buttonFocusFgColor = "${bg1}";
            buttonFocusBgColor = "${blue}";
            labelFgColor = "${orange}";
            fieldFgColor = "${blue}";
          };
          frame = {
            border = {
              fgColor = "${green}";
              focusColor = "${green}";
            };
            menu = {
              fgColor = "${grey1}";
              keyColor = "${yellow}";
              numKeyColor = "${yellow}";
            };
            crumbs = {
              fgColor = "${bg1}";
              bgColor = "${green}";
              activeColor = "${yellow}";
            };
            status = {
              newColor = "${blue}";
              modifyColor = "${green}";
              addColor = "${grey1}";
              pendingColor = "${orange}";
              errorColor = "${red}";
              highlightColor = "${yellow}";
              killColor = "${purple}";
              completedColor = "${grey1}";
            };
            title = {
              fgColor = "${blue}";
              bgColor = "${bg0}";
              highlightColor = "${purple}";
              counterColor = "${foreground}";
              filterColor = "${blue}";
            };
          };
          views = {
            charts = {
              bgColor = "${bg0}";
              defaultDialColors = [
                "${green}"
                "${red}"
              ];
              defaultChartColors = [
                "${green}"
                "${red}"
              ];
            };
            table = {
              fgColor = "${yellow}";
              bgColor = "${bg0}";
              cursorFgColor = "${bg1}";
              cursorBgColor = "${blue}";
              markColor = "${yellow}";
              header = {
                fgColor = "${grey1}";
                bgColor = "${bg0}";
                sorterColor = "${orange}";
              };
            };
            xray = {
              fgColor = "${blue}";
              bgColor = "${bg0}";
              cursorColor = "${foreground}";
              graphicColor = "${yellow}";
              showIcons = false;
            };
            yaml = {
              keyColor = "${green}";
              colonColor = "${grey1}";
              valueColor = "${grey1}";
            };
            logs = {
              fgColor = "${grey1}";
              bgColor = "${bg0}";
              indicator = {
                fgColor = "${blue}";
                bgColor = "${bg0}";
              };
            };
            help = {
              fgColor = "${grey1}";
              bgColor = "${bg0}";
              indicator = {
                fgColor = "${blue}";
              };
            };
          };
        };
      };
    };
    # zsh shortcut
    programs.zsh.initExtra = ''
      bindkey -s ^k "k9s\n"
    '';
    # my scripts relevant to k9s
    home.sessionPath = ["$HOME/.local/scripts"];
    home.file.".local/scripts/application.k9s.openHomeKube" = lib.mkIf config.homeManagerModules.guiApps.enable {
      executable = true;
      text = ''
        #!/bin/sh
        ${terminal} ${pkgs.k9s}/bin/k9s --kubeconfig /home/ben/.config/kube/config-home
      '';
    };
    home.file.".local/scripts/application.k9s.openWorkKube" = lib.mkIf config.homeManagerModules.guiApps.enable {
      executable = true;
      text = ''
        #!/bin/sh
        ${terminal} ${pkgs.k9s}/bin/k9s --kubeconfig /home/ben/.config/kube/config-work
      '';
    };
  };
}
