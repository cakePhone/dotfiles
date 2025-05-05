#!/usr/bin/env python3
import dbus
import dbus.mainloop.glib
from gi.repository import GLib
import subprocess

# Path to your script
SCRIPT_TO_RUN = "/home/oreo/.config/waybar/profiles.sh"


def on_properties_changed(interface, changed, invalidated):
    if "OnBattery" in changed:
        subprocess.Popen([SCRIPT_TO_RUN])


def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()
    upower = bus.get_object("org.freedesktop.UPower", "/org/freedesktop/UPower")
    bus.add_signal_receiver(
        on_properties_changed,
        dbus_interface="org.freedesktop.DBus.Properties",
        signal_name="PropertiesChanged",
        arg0="org.freedesktop.UPower",
    )
    loop = GLib.MainLoop()
    loop.run()


if __name__ == "__main__":
    main()
