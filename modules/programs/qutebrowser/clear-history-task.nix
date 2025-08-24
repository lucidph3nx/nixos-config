{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    nx.services.qutebrowser.clearHistoryTask =
      lib.mkEnableOption "A systemd service to clear qutebrowser history older than 7 days"
      // {
        # enable by default if qutebrowser is enabled
        default = config.nx.programs.qutebrowser.enable;
      };
  };
  config =
    lib.mkIf (config.nx.programs.qutebrowser.enable && config.nx.services.qutebrowser.clearHistoryTask)
      {
        home-manager.users.ben = {
          # a systemd service clear qutebrowser history older than 7 days
          systemd.user.services.clear-qutebrowser-history =
            let
              clear-qutebrowser-history =
                pkgs.writeShellScript "clear-qutebrowser-history"
                  # bash
                  ''
                    #!/bin/bash

                    # Path to your SQLite database
                    DB_PATH="/home/ben/.local/share/qutebrowser/history.sqlite"

                    # Delete entries older than 7 days
                    ${pkgs.sqlite}/bin/sqlite3 "$DB_PATH" <<EOF
                    DELETE FROM History WHERE atime < CAST(strftime('%s', 'now', '-7 days') AS INTEGER);
                    DELETE FROM CompletionHistory WHERE last_atime < CAST(strftime('%s', 'now', '-7 days') AS INTEGER);
                    EOF
                  '';
            in
            {
              Unit = {
                Description = "clear qutebrowser history older than 7 days";
                After = [ "network-online.target" ];
              };
              Service = {
                Type = "oneshot";
                ExecStart = clear-qutebrowser-history;
              };
              Install = {
                WantedBy = [ "default.target" ];
              };
            };
          systemd.user.timers.qutebrowser-clear-history-timer = {
            Unit = {
              Description = "Run clear qutebrowser history task every 1 hour";
            };
            Timer = {
              OnCalendar = "hourly";
              Persistent = true;
              Unit = "clear-qutebrowser-history.service";
            };
            Install = {
              WantedBy = [ "timers.target" ];
            };
          };
        };
      };
}
