---
description: Use the android-tools MCP server (19 tools over adb, emulator, and gradle) to run builds, drive emulators and devices, inspect UI, and read logs from Kimi Code. Covers prerequisites, tool groups, and typical workflows; also how to add Android Studio IDE tools via the JetBrains MCP Server plugin.
name: android-studio-mcp
---

# Android tools MCP integration

This plugin ships an MCP server named `android` (command `python3 ./bin/android-mcp`,
stdlib-only Python). It resolves the SDK from `ANDROID_SDK_ROOT` / `ANDROID_HOME` /
`~/Library/Android/sdk`, falling back to `adb` on `PATH`.

## Prerequisites

1. Android SDK with `platform-tools` (adb). Check with the `sdk_info` tool.
2. A device or emulator for device tools: physical device with USB debugging, or
   create an AVD in Android Studio's Device Manager (`avd_list` shows existing ones).
3. Physical devices need developer mode + USB debugging enabled; the agent cannot
   accept the RSA authorization dialog on the device — accept it yourself once.

## Tool groups (19 tools)

- **Discovery**: `sdk_info`, `device_list`, `avd_list`
- **Emulators**: `emulator_start` (boots an AVD and waits for `sys.boot_completed`),
  `emulator_stop`, `wait_for_boot`
- **Apps**: `app_install`, `app_uninstall`, `app_launch` (via launcher activity)
- **UI inspection & interaction**: `screenshot` (PNG image back to the agent),
  `ui_dump` (uiautomator XML with bounds — parse `bounds="[x1,y1][x2,y2]"` to tap
  elements), `ui_tap`, `ui_swipe`, `ui_input_text` (escape spaces as `%s`),
  `ui_key` (KEYCODE_BACK / KEYCODE_HOME / KEYCODE_ENTER / ...)
- **Logs & shell**: `logcat` (with optional filter), `shell`
- **Builds**: `gradle` (any task list through the nearest `gradlew`, tail of output
  returned), `gradle_tasks`

## Typical workflows

**Build and fix errors**: `gradle` with `["build"]` (or `assembleDebug`) → read the
error from the returned tail → edit code → repeat.

**Run on an emulator**: `avd_list` → `emulator_start` → `gradle`
`["assembleDebug"]` → `app_install` → `app_launch` → `logcat` for crashes.

**Verify a screen visually**: `screenshot` → if layout is wrong, `ui_dump` to get
element bounds → fix → `screenshot` again.

**Walk through a flow**: `ui_dump` → `ui_tap` on a control's center → `screenshot`
to confirm → repeat. Use `ui_key KEYCODE_BACK` to go back.

## Android Studio IDE tools (optional)

For editor-level tools (build from the IDE, run configurations, refactoring,
file search, terminal) install JetBrains' official MCP Server plugin:

```sh
./scripts/install-jetbrains-mcp-plugin.sh
```

Then in Android Studio: **Settings → Tools → MCP Server** → enable the server
(note the port, e.g. 64342). Add a stdio bridge to Kimi Code's user-level
`~/.kimi-code/mcp.json` — the config to paste is offered by the IDE as
"Copy Stdio Config" in the MCP Server settings, or use the `android-studio-ide`
entry from this plugin's README. The server is `Android Studio MCP Server`
(21 tools: build_project, execute_run_configuration, rename_refactoring,
search_in_files_by_regex, execute_terminal_command, ...). It works only while
Android Studio is running.

## Notes

- Compose Multiplatform projects (e.g. `features/android`): `gradle` handles the
  Android target like any module — `:composeApp:assembleDebug`, `:composeApp:testDebugUnitTest`.
- Prefer `gradle` over shelling out to `./gradlew` directly: the tool finds the
  wrapper and returns a trimmed, readable tail.
- `ui_input_text` needs `%s` for spaces (`"hello%%s world"` in JSON); keep strings short.
