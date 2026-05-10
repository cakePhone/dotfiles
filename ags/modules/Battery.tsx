import Battery from "gi://AstalBattery"
import { createBinding } from "ags"
import { execAsync } from "ags/process"
import { Icons } from "../icons"

const levels = [
  Icons.batteryEmpty,
  Icons.batteryQuarter,
  Icons.batteryHalf,
  Icons.batteryThreeQuarters,
  Icons.batteryFull,
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
      <label
        label={percentage((pct: number) => levels[Math.min(Math.max(Math.floor(pct * 100 / 20), 0), 4)])}
        tooltip-text={percentage((pct: number) => {
          const s = stateLabel[bat.state] || ""
          return `${Math.round(pct * 100)}% ${s}`.trim()
        })}
      />
    </button>
  )
}
