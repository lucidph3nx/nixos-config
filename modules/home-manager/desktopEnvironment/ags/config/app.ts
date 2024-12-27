import { App } from "astal/gtk3"
import style from "./style.scss"
import Overview from "./widget/Overview"

App.start({
  css: style,
  requestHandler(request: string, res: (response: any) => void) {
    if (request == "show") {
      res("showing overview")
      App.get_window("overview")!.show()
    }
    if (request == "hide") {
      res("hiding overview")
      App.get_window("overview")!.hide()
    }
    res("unknown command")
  },
  main() {
    App.get_monitors().map(Overview)
    // start hidden
    App.get_window("overview")!.hide()
  },
})
