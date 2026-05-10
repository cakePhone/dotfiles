import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import GLib from "gi://GLib"
import { Icons } from "../icons"

let prevTotal = 0
let prevIdle = 0

function readCpu(): string {
  try {
    const [ok, data] = GLib.file_get_contents("/proc/stat")
    if (!ok || !data) return "0%"
    const lines = new TextDecoder().decode(data).split("\n")
    const cpu = lines.find((l: string) => l.startsWith("cpu "))
    if (!cpu) return "0%"
    const parts = cpu.trim().split(/\s+/).slice(1).map(Number)
    const total = parts.reduce((a: number, b: number) => a + b, 0)
    const idle = parts[3] || 0

    if (prevTotal === 0) {
      prevTotal = total
      prevIdle = idle
      return "0%"
    }

    const dTotal = total - prevTotal
    const dIdle = idle - prevIdle
    prevTotal = total
    prevIdle = idle

    if (dTotal === 0) return "0%"
    return `${Math.round((1 - dIdle / dTotal) * 100)}%`
  } catch {
    return "0%"
  }
}

export default function CpuModule() {
  const usage = createPoll("0%", 5000, readCpu)

  return (
    <button
      class="module cpu"
      onClicked={() => execAsync("ghostty -e btop")}
    >
      <label label={Icons.cpu} tooltip-text={usage} />
    </button>
  )
}
