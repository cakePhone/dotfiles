import Tray from "gi://AstalTray"
import GLib from "gi://GLib"
import { Gtk } from "ags/gtk4"
import { createBinding, createState, For } from "ags"
import { Icons } from "../icons"

export default function SysTray() {
  const tray = Tray.get_default()
  const items = createBinding(tray, "items")
  const [collapsed, setCollapsed] = createState(true)
  let leaveTimer = 0

  function scheduleClose() {
    if (leaveTimer > 0) GLib.source_remove(leaveTimer)
    leaveTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => {
      setCollapsed(true)
      leaveTimer = 0
      return GLib.SOURCE_REMOVE
    })
  }

  function cancelClose() {
    if (leaveTimer > 0) {
      GLib.source_remove(leaveTimer)
      leaveTimer = 0
    }
  }

  return (
    <box
      orientation={Gtk.Orientation.VERTICAL}
      $={(self: any) => {
        const ctrl = new Gtk.EventControllerMotion()
        ctrl.connect("enter", () => {
          cancelClose()
          setCollapsed(false)
        })
        ctrl.connect("leave", () => scheduleClose())
        self.add_controller(ctrl)
      }}
    >
      <button
        class="module tray"
        onClicked={() => setCollapsed((c: boolean) => !c)}
      >
        <label label={collapsed((c: boolean) => (c ? Icons.tray : Icons.trayExpanded))} />
      </button>
      <revealer
        revealChild={collapsed((c: boolean) => !c)}
        transition-type={Gtk.RevealerTransitionType.SLIDE_DOWN}
      >
        <box orientation={Gtk.Orientation.VERTICAL}>
          <For each={items}>
            {(item: any) => (
              <menubutton
                class="module tray"
                tooltip-text={item.tooltip_markup || ""}
                $={(self: any) => {
                  self.menuModel = item.menu_model
                  self.insert_action_group("dbusmenu", item.action_group)
                }}
              >
                <image gicon={createBinding(item, "gicon")} />
              </menubutton>
            )}
          </For>
        </box>
      </revealer>
    </box>
  )
}
