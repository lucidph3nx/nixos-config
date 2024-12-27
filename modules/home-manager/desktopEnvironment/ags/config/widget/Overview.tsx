import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, GLib, bind } from "astal"
import Hyprland from "gi://AstalHyprland"
import NowPlaying from "../lib/mpd"
import DynamicProperty from "../lib/DynamicProperty"

function Workspaces() {
  const hypr = Hyprland.get_default();
  return <box
    name="workspaces"
    className="WorkspaceBar"
    margin={20}
    application={App}>
    <box className="Workspaces">
      {bind(hypr, "workspaces").as(wss => {
        const workspaces = new Array(9).fill(null).map((_, i) => {
          // Try to find a workspace with the current ID (i+1)
          const ws = wss.find(workspace => workspace.id === (i + 1));
          return ws || { id: i + 1, name: `${i + 1}`, placeholder: true }; // If not found, create a placeholder
        });

        return workspaces
          .sort((a, b) => a.id - b.id)  // Ensure workspaces are sorted
          .map(ws => (
            <box
              className={bind(hypr, "focusedWorkspace").as(fw =>
                ws === fw ? "workspace focused" : "workspace notfocused" + (ws.placeholder ? " placeholder" : ""))}  // Add "workspace placeholder" for placeholders
              halign={Gtk.Align.FILL}
              valign={Gtk.Align.FILL}>
              <label
                label={ws.name}
                hexpand={true}
                vexpand={true}
                halign={Gtk.Align.CENTER}
                valign={Gtk.Align.CENTER}
                xalign={0.5}
                yalign={0.5}
              />
            </box>
          ));
      })}
    </box>
  </box>
}

function FocusedClient() {
  const hypr = Hyprland.get_default()
  const focused = bind(hypr, "focusedClient")

  return <box
    name="focusedclient"
    className="FocusedClient"
    margin={25}
    application={App}>
    <box
      className="FocusedClientContent"
      halign={Gtk.Align.FILL}
      valign={Gtk.Align.FILL}
      visible={focused.as(Boolean)}>
      {focused.as(client => (
        client && <label
          label={bind(client, "title").as(String)}
          hexpand={true}
          vexpand={true}
          halign={Gtk.Align.CENTER}
          valign={Gtk.Align.CENTER}
          xalign={0.5}
          yalign={0.5}
          margin={25}
        />
      ))}
    </box>
  </box>
}

// a generic widget that displays the output of a script
function ScriptWidget({ scriptPath, refreshInterval }) {
  const dynamicProperty = DynamicProperty.get_instance(scriptPath, refreshInterval);

  return (
    <box visible={bind(dynamicProperty, "value", value => value !== "")}>
      <label label={bind(dynamicProperty, "value")} />
    </box>
  );
}


function MPD() {
  const nowPlaying = NowPlaying.get_default();

  // Bind the `nowPlaying` property to a variable
  const nowPlayingText = bind(nowPlaying, "nowPlaying");
  return (
    <box
      name="mpd"
      className="NowPlaying"
      margin={20}
      application={App}
      visible={nowPlayingText}>
      <box
        className="NowPlayingContent"
        halign={Gtk.Align.FILL}
        valign={Gtk.Align.FILL}>
        {/* Use the nowPlayingText variable here */}
        <label
          label={nowPlayingText}
          margin={25}
        />
      </box>
    </box>
  );
}

function EnvironmentSensors() {
  return <box
    className="EnvironmentSensors"
    application={App}
    margin={10}
    halign={Gtk.Align.END}
  >
    <box margin-left={20} margin-right={10}>
       <ScriptWidget
        scriptPath="/home/ben/.local/scripts/cli.home.office.getTemperature"
        refreshInterval={60}
      />
    </box>
    <box margin-left={10} margin-right={20}>
       <ScriptWidget
        scriptPath="/home/ben/.local/scripts/cli.home.office.getHumidity"
        refreshInterval={60}
      />
    </box>
  </box>;
}

function Time({ format = "%F %H:%M:%S" }) {
  const time = Variable<string>("").poll(1000, () =>
    GLib.DateTime.new_now_local().format(format)!)

  return <box
    name="time"
    className="Time"
    margin={10}
    halign={Gtk.Align.END}
    valign={Gtk.Align.FILL}
    application={App}>
    <label
      margin={25}
      onDestroy={() => time.drop()}
      label={time()}
    />
  </box>
}

export default function Overview(gdkmonitor: Gdk.Monitor) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

  return <window
    name="overview"
    className="Overview"
    gdkmonitor={gdkmonitor}
    application={App}
  >
    <box className="OverviewContent">
      <window className="TopLeft" anchor={TOP | LEFT}>
        <Workspaces />
      </window>
      <window className="TopCenter" anchor={TOP}>
        <FocusedClient />
      </window>
      <window className="TopRight" anchor={TOP | RIGHT}>
        <box margin={20} orientation={Gtk.Orientation.VERTICAL}>
          <Time />
          <EnvironmentSensors />
        </box>
      </window>
      <window className="BottomLeft" anchor={BOTTOM | LEFT}>
        <MPD />
      </window>
    </box>
  </window>
}
