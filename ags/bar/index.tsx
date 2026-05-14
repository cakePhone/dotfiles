import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import NiriTaskbar from "../modules/NiriTaskbar"
import Clock from "../modules/Clock"
import RecordingIndicator from "../modules/RecordingIndicator"
import Tray from "../modules/Tray"
import Network from "../modules/Network"
import Bluetooth from "../modules/Bluetooth"
import Audio from "../modules/Audio"
import Cpu from "../modules/Cpu"
import Battery from "../modules/Battery"

const { TOP, LEFT, BOTTOM } = Astal.WindowAnchor

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const mainBox = (
    <box orientation={Gtk.Orientation.VERTICAL}>
      <box orientation={Gtk.Orientation.VERTICAL} class="modules-left" valign={Gtk.Align.START} halign={Gtk.Align.CENTER}>
        <NiriTaskbar />
      </box>
      <box hexpand vexpand />
      <box orientation={Gtk.Orientation.VERTICAL} class="modules-right" valign={Gtk.Align.END} halign={Gtk.Align.CENTER}>
        <Tray gdkmonitor={gdkmonitor} />
        <Bluetooth />
        <Network />
        <Audio />
        <Cpu />
        <Battery />
      </box>
    </box>
  )

  const clockBox = (
    <box orientation={Gtk.Orientation.VERTICAL} valign={Gtk.Align.CENTER} halign={Gtk.Align.CENTER}>
      <Clock />
      <RecordingIndicator />
    </box>
  )

  const overlay = new Gtk.Overlay()
  overlay.set_child(mainBox)
  overlay.add_overlay(clockBox)

  return (
    <window
      visible
      name="bar"
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | BOTTOM}
      application={app}
      width-request={32}
    >
      {overlay}
    </window>
  )
}
