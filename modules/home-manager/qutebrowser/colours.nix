{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.homeManagerModules.qutebrowser.enable {
    programs.qutebrowser.settings = {
      colors = with config.theme; {
        webpage = {
          preferred_color_scheme = "${type}";
        };
        keyhint = {
          fg = "${foreground}";
          suffix.fg = "${red}";
          bg = "${bg0}";
        };
        messages = {
          error = {
            bg = "${bg_red}";
            fg = "${foreground}";
          };
          info = {
            bg = "${bg_blue}";
            fg = "${foreground}";
          };
          warning = {
            bg = "${bg_yellow}";
            fg = "${foreground}";
          };
        };
        prompts = {
          bg = "${bg0}";
          fg = "${foreground}";
        };
        completion = {
          category = {
            bg = "${bg3}";
            fg = "${foreground}";
          };
          fg = "${foreground}";
          even = {
            bg = "${bg0}";
          };
          odd = {
            bg = "${bg_dim}";
          };
          match = {
            fg = "${red}";
          };
          item = {
            selected = {
              fg = "${foreground}";
              bg = "${bg_yellow}";
              border = {
                top = "${bg_yellow}";
                bottom = "${bg_yellow}";
              };
            };
          };
          scrollbar = {
            bg = "${bg_dim}";
            fg = "${foreground}";
          };
        };
        hints = {
          bg = "${bg0}";
          fg = "${foreground}";
          match = {
            fg = "${red}";
          };
        };
        statusbar = {
          normal = {
            fg = "${foreground}";
            bg = "${bg3}";
          };
          insert = {
            fg = "${bg0}";
            bg = "${statusline1}";
          };
          caret = {
            fg = "${bg0}";
            bg = "${purple}";
          };
          command = {
            fg = "${foreground}";
            bg = "${bg0}";
          };
          passthrough = {
            fg = "${bg0}";
            bg = "${blue}";
          };
          url = {
            error = {
              fg = "${orange}";
            };
            fg = "${foreground}";
            hover = {
              fg = "${blue}";
            };
            success = {
              http = {
                fg = "${green}";
              };
              https = {
                fg = "${green}";
              };
            };
          };
        };
        tabs = {
          bar = {
            bg = "${bg_dim}";
          };
          even = {
            bg = "${bg0}";
            fg = "${foreground}";
          };
          odd = {
            bg = "${bg0}";
            fg = "${foreground}";
          };
          selected = {
            even = {
              bg = "${bg2}";
              fg = "${foreground}";
            };
            odd = {
              bg = "${bg2}";
              fg = "${foreground}";
            };
          };
          indicator = {
            start = "${blue}";
            stop = "${green}";
            error = "${red}";
          };
        };
      };
      hints.border = "0px solid black";
    };
  };
}
