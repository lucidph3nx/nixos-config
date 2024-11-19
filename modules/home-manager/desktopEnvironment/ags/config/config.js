const hyprland = await Service.import("hyprland")

const time = Variable("", {
    poll: [1000, 'date "+%H\n%M"'],
})

function Bar(monitor = 0) {
    return Widget.Window({
        name: `bar-${monitor}`, // name has to be unique
        class_name: "bar",
        monitor,
        anchor: ["left", "top", "right"],
        exclusivity: "exclusive",
        margins: [0, 0, 0, 0],
        child: Widget.CenterBox({
            class_name: "container",
            start_widget: Left(),
            end_widget: Right(),
        }),
    })
}

App.config({
    // style: "./style.css",
    windows: [
        Bar(),
    ],
})

function Left() {
    return Widget.Box({
        spacing: 8,
        vertical: true,
        children: [
            Workspaces(),
        ],
    })
}

function Right() {
    return Widget.Box({
        vpack: "end",
        spacing: 8,
        vertical: true,
        children: [
            Time(),
        ],
    })
}

function Workspaces() {
    const dispatch = ws => hyprland.messageAsync(`dispatch workspace ${ws}`);
    return Widget.Box({
        class_name: "workspaces",
        vertical: true,
        children: Array.from({ length: 10 }, (_, i) => i + 1).map(i => Widget.Button({
            attribute: i,
            label: `${i}`,
            onClicked: () => dispatch(i),
        })),

        setup: self => self.hook(hyprland, () => self.children.forEach(btn => {
            btn.visible = hyprland.workspaces.some(ws => ws.id === btn.attribute);
            btn.toggleClassName("focused", hyprland.active.workspace.id == btn.attribute);
        })),
    })
}

function Time() {
    return Widget.Label({
        class_name: "time",
        label: time.bind(),
    })
}

export { }
