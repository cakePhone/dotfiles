import Mpris from "gi://AstalMpris"
import { createBinding, For } from "ags"

const playerIcons: Record<string, string> = {
  default: "audio-x-generic-symbolic",
  spotify: "emblem-music-symbolic",
  firefox: "emblem-music-symbolic",
  chrome: "emblem-music-symbolic",
  vlc: "emblem-music-symbolic",
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
            <box>
              <image icon-name={status((s: number) => s === 1 ? "media-playback-pause-symbolic" : ico)} />
              <label label={status(() => ` ${title()} - ${artist()}`)} />
            </box>
          </button>
        )
      }}
    </For>
  )
}
