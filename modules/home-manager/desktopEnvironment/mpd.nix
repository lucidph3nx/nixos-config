{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.mpd = {
      enable = lib.mkEnableOption "enables mpd";
    };
  };
  config = lib.mkIf config.homeManagerModules.mpd.enable {
    home.packages = with pkgs; [
      mpc # for commandline control
    ];
    services.mpd = {
      enable = true;
      musicDirectory = "/home/ben/music";
      network.listenAddress = "0.0.0.0";
      extraConfig = ''
        db_file            "~/.local/share/mpd/database"
        log_file           "syslog"
        auto_update "yes"
        playlist_directory "~/music/playlists"
        state_file         "~/.local/share/mpd/state"
        sticker_file       "~/.local/share/mpd/sticker.sql"
        restore_paused "yes"
        port "6600"
        audio_output {
                type            "pulse"
                name            "pulse audio"
        }
        audio_output {
            type                    "fifo"
            name                    "my_fifo"
            path                    "/tmp/mpd.fifo"
            format                  "44100:16:2"
        }
      '';
    };
    # needed for playerctl to access mpd
    services.mpdris2 = {
      enable = true;
      mpd.host = "0.0.0.0";
    };
    home.persistence."/persist/home/ben" = {
      directories = [
        ".local/share/mpd"
      ];
    };
  };
}
