import Network from "gi://AstalNetwork"
import { createBinding } from "ags"
import { execAsync } from "ags/process"
import { Icons } from "../icons"

const wifiIcons = [Icons.wifi1, Icons.wifi2, Icons.wifi3, Icons.wifi4]

export default function NetworkModule() {
  const net = Network.get_default()
  const primary = createBinding(net, "primary")

  return (
    <button
      class="module network"
      onClicked={() => execAsync("bash ~/dotfiles/scripts/network-menu")}
    >
      <label
        label={primary((p: number) => {
          if (p === 2) {
            const w = net.wifi
            const strength = w?.strength || 0
            return wifiIcons[Math.min(Math.floor(strength / 25), 3)]
          }
          if (p === 1) return Icons.ethernet
          return Icons.disconnected
        })}
      />
    </button>
  )
}
