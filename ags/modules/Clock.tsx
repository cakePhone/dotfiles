import GLib from "gi://GLib"
import { createPoll } from "ags/time"
import { execAsync } from "ags/process"

export default function Clock() {
  const time = createPoll("", 1000, () => {
    const now = GLib.DateTime.new_now_local()
    return now.format("%a\n%Hh\n%Mm") || ""
  })

  return (
    <button class="module clock" onClicked={() => execAsync("xdg-terminal-exec")}>
      <label label={time} />
    </button>
  )
}
