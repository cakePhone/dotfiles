import Battery from "gi://AstalBattery"
import { createBinding } from "ags"
import { execAsync } from "ags/process"

const themeLevels = [
  "battery-empty-symbolic",
  "battery-quarter-symbolic",
  "battery-half-symbolic",
  "battery-three-quarters-symbolic",
  "battery-full-symbolic",
]

const stateLabel: Record<number, string> = {
  [1]: "Charging",
  [2]: "Discharging",
  [4]: "Fully Charged",
}

export default function BatteryModule() {
  const bat = Battery.get_default()
  const percentage = createBinding(bat, "percentage")

  return (
    <button
      class="module battery"
      onClicked={() => execAsync("bash ~/dotfiles/scripts/toggle_power_mode.sh niri")}
    >
      <image
        icon-name={percentage((pct: number) => themeLevels[Math.min(Math.max(Math.floor(pct * 100 / 20), 0), 4)])}
        tooltip-text={percentage((pct: number) => {
          const s = stateLabel[bat.state] || ""
          return `${Math.round(pct * 100)}% ${s}`.trim()
        })}
      />
    </button>
  )
}
