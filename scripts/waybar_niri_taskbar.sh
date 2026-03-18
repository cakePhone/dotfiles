#!/usr/bin/env python3

import json
import subprocess
import sys
import shutil
import time


APP_ICONS = {
    "org.mozilla.firefox": "",
    "firefox": "",
    "zen": "",
    "org.chromium.chromium": "",
    "chromium": "",
    "google-chrome": "",
    "org.gnome.nautilus": "",
    "nautilus": "",
    "org.kde.dolphin": "",
    "com.mitchellh.ghostty": "",
    "vesktop": "",
    "discord": "",
    "element": "󰘨",
    "org.telegram.desktop": "",
    "signal": "󰭹",
    "spotify": "",
    "alacritty": "",
    "foot": "",
    "kitty": "",
    "org.wezfurlong.wezterm": "",
    "code": "󰨞",
    "codium": "󰨞",
    "steam": "",
}


def read_json(command):
    try:
        out = subprocess.check_output(command, stderr=subprocess.DEVNULL, text=True)
        data = json.loads(out)
        if isinstance(data, list):
            return data
        if isinstance(data, dict):
            for key in ("windows", "items", "data"):
                value = data.get(key)
                if isinstance(value, list):
                    return value
        return []
    except Exception:
        return []


def pick(d, keys, default=None):
    for k in keys:
        if k in d and d[k] is not None:
            return d[k]
    return default


def normalize_workspace_id(win):
    workspace = win.get("workspace")
    if isinstance(workspace, dict):
        return pick(workspace, ["id", "idx", "index", "name"])
    return pick(win, ["workspace_id", "workspace_idx", "workspace_index", "workspace_name"])


def normalize_sort(win, idx):
    workspace = win.get("workspace") if isinstance(win.get("workspace"), dict) else {}
    layout = win.get("layout") if isinstance(win.get("layout"), dict) else {}

    pos = layout.get("pos_in_scrolling_layout")
    pos_col = None
    pos_row = None
    if isinstance(pos, list) and len(pos) >= 2:
        pos_col, pos_row = pos[0], pos[1]

    workspace_index = pick(
        win,
        ["workspace_idx", "workspace_index", "workspace_id"],
        pick(workspace, ["idx", "index"], 0),
    )
    column_index = pick(
        win,
        ["column_idx", "column_index", "column", "tile_column"],
        pick(layout, ["column", "column_index"], pos_col if pos_col is not None else 0),
    )
    row_index = pick(
        win,
        ["row_idx", "row_index", "row", "tile_row"],
        pick(layout, ["row", "row_index"], pos_row if pos_row is not None else 0),
    )
    x = pick(win, ["x"], 0)
    y = pick(win, ["y"], 0)

    return (
        int(workspace_index) if isinstance(workspace_index, (int, float)) else 0,
        int(column_index) if isinstance(column_index, (int, float)) else 0,
        int(row_index) if isinstance(row_index, (int, float)) else 0,
        int(x) if isinstance(x, (int, float)) else 0,
        int(y) if isinstance(y, (int, float)) else 0,
        idx,
    )


def icon_for(app_id):
    if not app_id:
        return "󰣆"

    lowered = str(app_id).lower().strip()

    # Exact app_id match first.
    if lowered in APP_ICONS:
        return APP_ICONS[lowered]

    # Try progressively shorter dotted segments, e.g. com.foo.Bar -> bar.
    parts = [p for p in lowered.replace("-", ".").replace("_", ".").split(".") if p]
    for i in range(len(parts)):
        candidate = ".".join(parts[i:])
        if candidate in APP_ICONS:
            return APP_ICONS[candidate]

    # Fallback: substring matching for odd app IDs.
    for key, icon in APP_ICONS.items():
        if key in lowered:
            return icon

    return "󰣆"


def build_payload():
    if shutil.which("niri") is None:
        return {"text": "?", "class": "error", "tooltip": "niri not found in PATH"}

    windows = read_json(["niri", "msg", "--json", "windows"])

    focused_window = None
    normalized = []
    for idx, win in enumerate(windows):
        if not isinstance(win, dict):
            continue
        focused = bool(pick(win, ["is_focused", "focused", "active"], False))
        app_id = pick(win, ["app_id", "app", "class"], "")
        title = pick(win, ["title", "window_title", "name"], app_id or "Window")
        workspace_id = normalize_workspace_id(win)
        item = {
            "focused": focused,
            "app_id": str(app_id) if app_id else "",
            "title": str(title),
            "workspace_id": workspace_id,
            "sort_key": normalize_sort(win, idx),
        }
        normalized.append(item)
        if focused:
            focused_window = item

    if not normalized:
        return {"text": "·", "class": "empty", "tooltip": "No windows"}

    focused_workspace = focused_window["workspace_id"] if focused_window else None

    def priority(item):
        return 0 if focused_workspace is not None and item["workspace_id"] == focused_workspace else 1

    normalized.sort(key=lambda item: (priority(item), item["sort_key"]))

    text_parts = []
    tooltip_parts = []
    for i, item in enumerate(normalized, start=1):
        icon = icon_for(item["app_id"])
        if item["focused"]:
            text_parts.append(icon)
        else:
            text_parts.append("<span alpha='50%%'>%s</span>" % icon)
        tooltip_parts.append(f"{i}. {item['title']}")

    return {
        "text": "\n".join(text_parts),
        "tooltip": "\\n".join(tooltip_parts),
        "class": "focused" if focused_window else "normal",
    }


def emit_payload():
    print(json.dumps(build_payload(), ensure_ascii=False), flush=True)


def watch_loop():
    emit_payload()
    while True:
        try:
            proc = subprocess.Popen(
                ["niri", "msg", "--json", "event-stream"],
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
            )
        except Exception:
            time.sleep(1)
            emit_payload()
            continue

        if proc.stdout is None:
            time.sleep(1)
            emit_payload()
            continue

        for _line in proc.stdout:
            emit_payload()

        time.sleep(0.2)


def main():
    if "--watch" in sys.argv:
        watch_loop()
        return

    emit_payload()


if __name__ == "__main__":
    try:
        main()
    except Exception:
        print(json.dumps({"text": "", "class": "empty", "tooltip": "No windows"}))
        sys.exit(0)
