import GObject, { register, property } from "astal/gobject";
import { execAsync } from "astal/process";
const GLib = imports.gi.GLib;

@register({ GTypeName: "NowPlaying" })
export default class NowPlaying extends GObject.Object {
    static instance;

    static get_default() {
        if (!this.instance) this.instance = new NowPlaying();
        return this.instance;
    }

    #nowPlaying = "";

    @property(String)
    get nowPlaying() {
        return this.#nowPlaying;
    }

    set nowPlaying(value) {
        if (this.#nowPlaying !== value) {
            this.#nowPlaying = value;
            this.notify("now-playing"); // Notify the property system of the change
        }
    }

    constructor() {
        super();

        // Poll every second to update the nowPlaying string
        GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, () => {
            this.updateNowPlaying();
            return true; // Continue the timeout
        });
    }

    async updateNowPlaying() {
        try {
            const result = await execAsync("/home/ben/.local/scripts/cli.mpd.nowPlaying");
            this.nowPlaying = result.trim(); // Set the property, triggering notification
        } catch (error) {
            console.error("Error fetching nowPlaying:", error);
        }
    }
}
