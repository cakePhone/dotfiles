import Wp from "gi://AstalWp"
import { createBinding } from "ags"
import { Icons } from "../icons"

const iconMap: Record<string, string> = {
  "audio-volume-muted-symbolic": Icons.volumeMute,
  "audio-volume-low-symbolic": Icons.volumeLow,
  "audio-volume-medium-symbolic": Icons.volumeMedium,
  "audio-volume-high-symbolic": Icons.volumeHigh,
  "audio-headphones-symbolic": Icons.headphone,
  "audio-headset-symbolic": Icons.headphone,
}

export default function AudioModule() {
  const speaker = Wp.get_default().get_default_speaker()

  return (
    <button class="module audio" onClicked={() => speaker.set_mute(!speaker.mute)}>
      <label
        label={createBinding(speaker, "volume-icon")((icon: string) => iconMap[icon] || Icons.volumeHigh)}
      />
    </button>
  )
}
