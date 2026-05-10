import Bluetooth from "gi://AstalBluetooth"
import { createBinding } from "ags"
import { Icons } from "../icons"

export default function BluetoothModule() {
  const bt = Bluetooth.get_default()
  const powered = createBinding(bt, "is-powered")

  return (
    <button class="module bluetooth">
      <label label={powered((p: boolean) => (p ? Icons.bluetooth : Icons.bluetoothOff))} />
    </button>
  )
}
