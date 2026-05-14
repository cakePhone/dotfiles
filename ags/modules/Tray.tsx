import Tray from "gi://AstalTray"
import { Gtk } from "ags/gtk4"
import { createBinding, For } from "ags"

export default function SysTray() {
  const tray = Tray.get_default()
  const items = createBinding(tray, "items")

  return (
    <menubutton class="module tray" direction={Gtk.ArrowType.RIGHT}>
      <image icon-name="open-menu-symbolic" />
      <popover>
        <box orientation={Gtk.Orientation.VERTICAL}>
          <For each={items}>
            {(item: any) => (
              <menubutton
                class="module tray-item"
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
      </popover>
    </menubutton>
  )
}
