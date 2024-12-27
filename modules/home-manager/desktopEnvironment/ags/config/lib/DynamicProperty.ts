import GObject, { register, property } from "astal/gobject";
import { execAsync } from "astal/process";
const GLib = imports.gi.GLib;

@register({ GTypeName: "DynamicProperty" })
export default class DynamicProperty extends GObject.Object {
    static instances = new Map();

    static get_instance(scriptPath, refreshInterval) {
        if (!scriptPath || !refreshInterval) {
            throw new Error("scriptPath and refreshInterval must be provided");
        }

        const key = `${scriptPath}:${refreshInterval}`;
        if (!this.instances.has(key)) {
            this.instances.set(key, new DynamicProperty(scriptPath, refreshInterval));
        }
        return this.instances.get(key);
    }

    #value = "";
    #scriptPath;
    #refreshInterval;

    @property(String)
    get value() {
        return this.#value;
    }

    set value(newValue) {
        if (this.#value !== newValue) {
            this.#value = newValue;
            this.notify("value");
        }
    }

    constructor(scriptPath, refreshInterval) {
        if (!scriptPath || !refreshInterval) {
            throw new Error("scriptPath and refreshInterval must be provided");
        }

        super();

        this.#scriptPath = scriptPath;
        this.#refreshInterval = refreshInterval;

        GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, this.#refreshInterval, () => {
            this.updateValue();
            return true;
        });

        this.updateValue();
    }

    async updateValue() {
        try {
            const result = await execAsync(this.#scriptPath);
            this.value = result.trim();
        } catch (error) {
            console.error(`Error fetching value from ${this.#scriptPath}:`, error);
        }
    }
}
