import Bluetooth from "gi://AstalBluetooth"
import { createBinding } from "ags"
import { execAsync } from "ags/process"

export default function BluetoothModule() {
  const bt = Bluetooth.get_default()
  const powered = createBinding(bt, "is-powered")

  return (
    <button class="module bluetooth" onClicked={() => execAsync("ghostty -e bluetui")}>
      <image icon-name={powered((p: boolean) => (p ? "bluetooth-active-symbolic" : "bluetooth-disabled-symbolic"))} />
    </button>
  )
}
