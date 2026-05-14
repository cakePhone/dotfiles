import { Gtk, Gdk } from "ags/gtk4"
import GLib from "gi://GLib"

let theme: Gtk.IconTheme | null = null

function getTheme(): Gtk.IconTheme {
  if (!theme) {
    theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default())
  }
  return theme
}

const cache = new Map<string, string | null>()
const desktopDirs = [
  `${GLib.get_home_dir()}/.local/share/applications`,
  "/usr/local/share/applications",
  "/usr/share/applications",
  "/var/lib/flatpak/exports/share/applications",
  `${GLib.get_home_dir()}/.local/share/flatpak/exports/share/applications`,
]

function findDesktopFile(appId: string): string | null {
  const candidates = [
    ...(appId.endsWith(".desktop") ? [appId] : [`${appId}.desktop`]),
    appId,
    ...(appId.endsWith(".desktop") ? [appId.toLowerCase()] : [`${appId.toLowerCase()}.desktop`]),
    appId.toLowerCase(),
  ]
  for (const c of [...new Set(candidates)]) {
    for (const dir of desktopDirs) {
      const path = `${dir}/${c}`
      if (GLib.file_test(path, GLib.FileTest.EXISTS)) return path
    }
  }
  return null
}

function parseDesktopIcon(path: string): string | null {
  try {
    const [ok, data] = GLib.file_get_contents(path)
    if (!ok || !data) return null
    const m = new TextDecoder().decode(data).match(/^Icon=(.+)$/m)
    return m ? m[1].trim() : null
  } catch {
    return null
  }
}

export function clearCache(): void {
  cache.clear()
}

export function getAppIconName(appId: string | null): string | null {
  if (!appId) return null
  const cached = cache.get(appId)
  if (cached !== undefined) return cached

  try {
    const t = getTheme()
    const parts = appId.split(".")
    const raw = [
      appId,
      appId.toLowerCase(),
      appId.replace(/\./g, "-"),
      appId.toLowerCase().replace(/\./g, "-"),
      ...parts.slice().reverse(),
      parts[parts.length - 1],
      (parts[parts.length - 1] || "").toLowerCase(),
    ]
    const candidates = [
      ...raw.map((n) => (n ? `${n}-symbolic` : null)),
      ...raw,
    ]

    for (const name of [...new Set(candidates)]) {
      if (name && t.has_icon(name)) {
        cache.set(appId, name)
        return name
      }
    }

    const desktopFile = findDesktopFile(appId)
    if (desktopFile) {
      const desktopIcon = parseDesktopIcon(desktopFile)
      if (desktopIcon && t.has_icon(desktopIcon)) {
        cache.set(appId, desktopIcon)
        return desktopIcon
      }
    }

    cache.set(appId, null)
    return null
  } catch {
    cache.set(appId, null)
    return null
  }
}
