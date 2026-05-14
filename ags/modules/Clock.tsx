import GLib from "gi://GLib"
import { createPoll } from "ags/time"
import { Gtk } from "ags/gtk4"

export default function Clock() {
  const time = createPoll("", 1000, () => {
    const now = GLib.DateTime.new_now_local()
    return now.format("%a\n%Hh\n%Mm") || ""
  })

  return (
    <menubutton class="module clock" direction={Gtk.ArrowType.RIGHT}>
      <label label={time} />
      <popover>
        <box
          orientation={Gtk.Orientation.VERTICAL}
          class="calendar-box"
          $={(self) => {
            const cal = new Gtk.Calendar()
            self.append(cal)
          }}
        />
      </popover>
    </menubutton>
  )
}
