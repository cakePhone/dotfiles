import Mpris from "gi://AstalMpris"
import { createBinding, For } from "ags"
import { Icons } from "../icons"

const playerIcons: Record<string, string> = {
  default: Icons.music,
  spotify: Icons.spotify,
  firefox: Icons.firefox,
  chrome: Icons.chrome,
  vlc: Icons.vlc,
}

export default function Media() {
  const mpris = Mpris.get_default()
  const players = createBinding(mpris, "players")

  return (
    <For each={players}>
      {(player: any) => {
        const title = createBinding(player, "title")
        const artist = createBinding(player, "artist")
        const status = createBinding(player, "playback-status")

        const icon = (busName: string) => {
          for (const [key, ico] of Object.entries(playerIcons)) {
            if (busName.toLowerCase().includes(key)) return ico
          }
          return playerIcons.default
        }
        const ico = icon(player.bus_name)

        return (
          <button class="module" onClicked={() => player.play_pause()}>
            <label
              label={status((s: number) => {
                const p = s === 1 ? Icons.paused : ico
                return `${p} ${title()} - ${artist()}`
              })}
            />
          </button>
        )
      }}
    </For>
  )
}
