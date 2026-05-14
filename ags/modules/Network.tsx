import Network from "gi://AstalNetwork"
import { createBinding } from "ags"
import { execAsync } from "ags/process"

const wifiThemeIcons = [
  "network-wireless-signal-none-symbolic",
  "network-wireless-signal-weak-symbolic",
  "network-wireless-signal-ok-symbolic",
  "network-wireless-signal-excellent-symbolic",
]

export default function NetworkModule() {
  const net = Network.get_default()
  const primary = createBinding(net, "primary")

  const iconName = primary((p: number) => {
    if (p === 2) {
      const w = net.wifi
      const strength = w?.strength || 0
      return wifiThemeIcons[Math.min(Math.floor(strength / 25), 3)]
    }
    if (p === 1) return "network-wired-symbolic"
    return "network-offline-symbolic"
  })

  return (
    <button
      class="module network"
      onClicked={() => execAsync("bash ~/dotfiles/scripts/network-menu")}
    >
      <image icon-name={iconName} />
    </button>
  )
}
