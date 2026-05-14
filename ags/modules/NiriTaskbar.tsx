import GLib from "gi://GLib"
import { Gtk } from "ags/gtk4"
import { execAsync, subprocess } from "ags/process"
import { createState, For, onCleanup } from "ags"
import { getAppIconName } from "./AppIcons"

function appLabel(appId: string | null, title: string | null): string {
  const id = appId || title || "?"
  const parts = id.split(".")
  const short = parts[parts.length - 1] || id
  return short.slice(0, 2).toUpperCase()
}

function sortKey(win: any): number[] {
  const ws = win.workspace_id ?? 0
  const layout = win.layout || {}
  const pos = layout.pos_in_scrolling_layout || [0, 0]
  return [Number(ws), Number(pos[0]) || 0, Number(pos[1]) || 0]
}

export default function NiriTaskbar() {
  const [windows, setWindows] = createState<any[]>([])

  async function fetchWindows() {
    try {
      const out = await execAsync("niri msg --json windows")
      const wins = JSON.parse(out)
      wins.sort((a: any, b: any) => {
        const ka = sortKey(a)
        const kb = sortKey(b)
        for (let i = 0; i < ka.length; i++) {
          if (ka[i] !== kb[i]) return ka[i] - kb[i]
        }
        return 0
      })
      setWindows(wins)
    } catch {
      setWindows([])
    }
  }

  fetchWindows()

  const stream = subprocess(["niri", "msg", "--json", "event-stream"], () =>
    fetchWindows(),
  )
  onCleanup(() => {
    try {
      stream.kill()
    } catch {}
  })

  return (
    <box class="taskbar" orientation={Gtk.Orientation.VERTICAL}>
      <For each={windows}>
        {(win: any, index: any) => {
          const i = index()
          const icon = getAppIconName(win.app_id)

          return (
            <button
              class={["taskbar-button", win.is_focused ? "focused" : ""]
                .filter(Boolean)
                .join(" ")}
              tooltip-text={win.title || win.app_id || "Window"}
              onClicked={() =>
                GLib.spawn_command_line_async(
                  `niri msg action focus-window --id ${win.id}`,
                )
              }
            >
              {icon ? (
                <image icon-name={icon} pixel-size={18} />
              ) : (
                <label label={appLabel(win.app_id, win.title)} />
              )}
            </button>
          )
        }}
      </For>
    </box>
  )
}
