{ config, pkgs, inputs, lib, ... }: {
  options = {
    k9s.enable =
      lib.mkEnableOption "enables k9s";
  };
  config = lib.mkIf config.k9s.enable {
    programs.k9s = {
      enable = true;
      settings = {
        k9s = {
          liveViewAutoRefresh = false;
          refreshRate = 2;
          maxConnRetry = 5;
          readOnly = false;
          noExitOnCtrlC = true;
          ui = {
            enableMouse = false;
            headless = true; logoless = false;
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
      skin = let
        foreground = "#d3c6aa";
        background = "#2d353b";
        black = "#343f44";
        blue = "#7fbbb3";
        green = "#a7c080";
        grey = "#859289";
        orange = "#e69875";
        purple = "#d699b6";
        red = "#e67e80";
        yellow = "#dbbc7f";
      in {
        k9s = {
          body = {
            fgColor = "${foreground}";
            bgColor = "${background}";
            logoColor = "${green}";
          };
          prompt = {
            fgColor = "${foreground}";
            bgColor = "${background}";
            suggestColor = "${orange}";
          };
          info = {
            fgColor = "${grey}";
            sectionColor = "${green}";
          };
          dialog = {
            fgColor = "${foreground}";
            bgColor = "${background}";
            buttonFgColor = "${foreground}";
            buttonBgColor = "${green}";
            buttonFocusFgColor = "${black}";
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
              fgColor = "${grey}";
              keyColor = "${yellow}";
              numKeyColor = "${yellow}";
            };
            crumbs = {
              fgColor = "${black}";
              bgColor = "${green}";
              activeColor = "${yellow}";
            };
            status = {
              newColor = "${blue}";
              modifyColor = "${green}";
              addColor = "${grey}";
              pendingColor = "${orange}";
              errorColor = "${red}";
              highlightColor = "${yellow}";
              killColor = "${purple}";
              completedColor = "${grey}";
            };
            title = {
              fgColor = "${blue}";
              bgColor = "${background}";
              highlightColor = "${purple}";
              counterColor = "${foreground}";
              filterColor = "${blue}";
            };
          };
          views = {
            charts = {
              bgColor = "${background}";
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
              bgColor = "${background}";
              cursorFgColor = "${black}";
              cursorBgColor = "${blue}";
              markColor = "${yellow}";
              header = {
                fgColor = "${grey}";
                bgColor = "${background}";
                sorterColor = "${orange}";
              };
            };
            xray = {
              fgColor = "${blue}";
              bgColor = "${background}";
              cursorColor = "${foreground}";
              graphicColor = "${yellow}";
              showIcons = false;
            };
            yaml = {
              keyColor = "${green}";
              colonColor = "${grey}";
              valueColor = "${grey}";
            };
            logs = {
              fgColor = "${grey}";
              bgColor = "${background}";
              indicator = {
                fgColor = "${blue}";
                bgColor = "${background}";
              };
            };
            help = {
              fgColor = "${grey}";
              bgColor = "${background}";
              indicator = {
                fgColor = "${blue}";
              };
            };
          };
        };
      };
    };
    # zsh shortcut
    home.programs.zsh.initExtra = ''
      bindkey -s ^k "k9s\n"
    '';
    # my scripts relevant to k9s
    home.sessionPath = ["$HOME/.local/scripts"];
    home.file.".local/scripts/application.k9s.openHomeKube" = {
      executable = true;
      text = ''
        #!/bin/sh
        kitty k9s --kubeconfig /home/ben/.config/kube/config-home
      '';
    };
    home.file.".local/scripts/application.k9s.openWorkKube" = {
      executable = true;
      text = ''
        #!/bin/sh
        kitty k9s --kubeconfig /home/ben/.config/kube/config-work
      '';
    };
  };
}
