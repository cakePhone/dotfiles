import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import { Icons } from "../icons"

export default function RecordingIndicator() {
  const recording = createPoll("idle", 2000,
    `bash -c "pgrep -x wf-recorder > /dev/null && echo active || echo idle"`,
  )

  return (
    <button
      class="module recording"
      onClicked={() => execAsync("bash ~/dotfiles/scripts/toggle-screenrecord")}
    >
      <label label={recording((r: string) => (r === "active" ? Icons.recording : ""))} />
    </button>
  )
}
