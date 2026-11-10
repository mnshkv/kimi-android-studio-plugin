# kimi-android-studio-plugin

**Use Android Studio and Android devices from [Kimi Code](https://www.kimi.com/code): builds, tests, emulators, screenshots, UI automation, logcat — over MCP.**

The Android counterpart of [kimi-xcode-plugin](https://github.com/mnshkv/kimi-xcode-plugin): where the Xcode plugin activates the MCP server Apple built into Xcode, this plugin ships its own stdio MCP server over `adb`, `emulator`, and `gradle` — because Android Studio, unlike Xcode, does not export one (yet).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: macOS / Linux / Windows](https://img.shields.io/badge/Platform-macOS%20%C2%B7%20Linux%20%C2%B7%20Windows-black.svg)]()
[![Kimi Code](https://img.shields.io/badge/Kimi%20Code-plugin-orange.svg)](https://www.kimi.com/code/docs/en/kimi-code-cli/customization/plugins.html)

## Features

| Area | Tools |
|---|---|
| Discovery | SDK/adb/emulator paths, connected devices, AVD list |
| Emulators | Boot an AVD and wait for it, stop, wait-for-boot |
| Apps | Install / uninstall / launch APKs |
| UI automation | Screenshots (PNG back to the agent), uiautomator hierarchy dumps, tap, swipe, text input, key events |
| Logs | logcat with filters, device shell |
| Builds | Any gradle task via the project's `gradlew` (`build`, `test`, `assembleDebug`, ...), task discovery |

Plus optional **Android Studio IDE tools** (editor access, run configurations) via JetBrains' official MCP Server plugin.

## Install

In any Kimi Code session:

```
/plugins install https://github.com/mnshkv/kimi-android-studio-plugin
```

Then `/plugins reload` (or start a new session).

Or from a local clone:

```
/plugins install /path/to/kimi-android-studio-plugin
```

## Requirements

- Android SDK with `platform-tools` (adb); `ANDROID_SDK_ROOT` / `ANDROID_HOME` honored
- For device features: an emulator (create one in Android Studio's Device Manager) or a physical device with USB debugging

## Usage

Open your Android/KMP project and just ask:

- "Build the app and fix any compile errors" (uses the project gradlew)
- "Boot the Pixel emulator, install the debug APK, and check that the home screen renders" (screenshot back to the agent)
- "Tap through onboarding and take a screenshot at each step"
- "Run the unit tests for the shared module and summarize failures"

The bundled `android-studio-mcp` skill documents all 19 tools and typical workflows.

## Optional: Android Studio IDE tools

Android Studio 2025.2+ can expose editor and run-configuration tools through
JetBrains' official MCP Server plugin:

```sh
./scripts/install-jetbrains-mcp-plugin.sh
```

Then enable it in **Settings → Tools → MCP Server** (port 63342) and add
`http://127.0.0.1:63342` to Kimi Code's MCP configuration.

## How it works

```
Kimi Code ──MCP (stdio)──▶ bin/android-mcp (Python 3, zero deps)
                                    ├── adb      devices, install, ui, logcat, shell
                                    ├── emulator AVD boot/stop
                                    └── gradlew  builds & tests
```

## Contributing

Issues and PRs welcome — more adb-backed tools, better gradle output parsing, Windows path handling.

## License

MIT.
