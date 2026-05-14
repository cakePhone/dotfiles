import Tray from "gi://AstalTray"
import { Gtk } from "ags/gtk4"

function buildContent(): Gtk.Box {
  const tray = Tray.get_default()
  const box = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    cssClasses: ["tray-popup-box"],
  })

  for (const item of tray.items) {
    if (!item) continue

    const btn = new Gtk.MenuButton({
      cssClasses: ["tray-item"],
      tooltipText: item.tooltip_markup || "",
    })
    btn.menuModel = item.menu_model
    btn.insert_action_group("dbusmenu", item.action_group)
    btn.child = new Gtk.Image({ gicon: item.gicon })
    box.append(btn)
  }

  return box
}

export default function SysTray() {
  let popover: Gtk.Popover | null = null

  const toggle = (self: Gtk.Widget) => {
    if (popover !== null && popover.get_visible()) {
      popover.popdown()
      return
    }

    if (!Tray.get_default().items?.length) return

    if (!popover) {
      popover = new Gtk.Popover({
        cssClasses: ["tray-popup"],
        hasArrow: false,
        position: Gtk.PositionType.RIGHT,
      })
      popover.set_parent(self)
    }

    popover.child = buildContent()
    popover.popup()
  }

  return (
    <button class="tray-button" onClicked={toggle}>
      <image icon-name="open-menu-symbolic" />
    </button>
  )
}
