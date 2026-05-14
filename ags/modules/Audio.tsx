import AstalWp from "gi://AstalWp"
import { createBinding } from "ags"
import { Gtk } from "ags/gtk4"

export default function Audio() {
  const speaker = AstalWp.Wp.get_default().defaultSpeaker
  const volume = createBinding(speaker, "volume")
  const volumeIcon = createBinding(speaker, "volume_icon")

  return (
    <menubutton class="module audio" direction={Gtk.ArrowType.RIGHT}>
      <image
        icon-name={volumeIcon((icon: string) => `${icon}-symbolic`)}
        tooltip-text={volume(
          (vol: number) => `Volume ${Math.floor(vol * 100)}%`,
        )}
      />
      <popover>
        <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
          <slider
            orientation={Gtk.Orientation.VERTICAL}
            inverted
            height-request={200}
            value={volume}
            onValueChanged={(self) => { speaker.volume = self.value }}
          />
        </box>
      </popover>
    </menubutton>
  )
}
