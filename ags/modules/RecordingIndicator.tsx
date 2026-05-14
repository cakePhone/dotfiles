import { createPoll } from "ags/time"
import { execAsync } from "ags/process"

export default function RecordingIndicator() {
  const recording = createPoll("idle", 2000,
    `bash -c "pgrep -x wf-recorder > /dev/null && echo active || echo idle"`,
  )

  return (
    <button
      class="module recording"
      onClicked={() => execAsync("bash ~/dotfiles/scripts/toggle-screenrecord")}
    >
      <image icon-name={recording((r: string) => (r === "active" ? "media-record-symbolic" : ""))} />
    </button>
  )
}
