<div align="center">

<img src="https://img.shields.io/badge/macOS-13%2B-black?style=flat-square&logo=apple&logoColor=white" />
<img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift&logoColor=white" />
<img src="https://img.shields.io/badge/No_Electron-✓-green?style=flat-square" />
<img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" />
<img src="https://img.shields.io/github/stars/rbc33/Ghostbar?style=flat-square&color=yellow" />

<br><br>

# ⬡ Ghostbar

### The only native Swift macOS Cluely alternative.

*No Electron. No subscription. No cloud. Just Swift.*  
*AI invisible to screen sharing — Zoom, Teams, Meet, OBS.*

<br>

[**Download DMG**](https://github.com/rbc33/Ghostbar/releases) · [**Homebrew**](#install-via-homebrew) · [**Build from source**](#install) · [**Report bug**](https://github.com/rbc33/Ghostbar/issues)

</div>

---

## Why Ghostbar over Pluely, Natively, or Vysper?

Every other Cluely alternative is built on **Electron or Tauri** — that means a bundled Chromium browser, 200–500MB of RAM just to open, and slow startup times.

Ghostbar is written in **native Swift using AppKit**. It starts instantly, uses minimal memory, and feels like a real macOS app — because it is one.

| | Ghostbar | Pluely | Natively | Vysper |
|---|---|---|---|---|
| **Tech** | ✅ Native Swift | Tauri/Rust | Electron | Electron |
| **macOS only** | ✅ Purpose-built | ❌ Cross-platform | ❌ Cross-platform | ❌ Cross-platform |
| **Ollama / local LLMs** | ✅ | ⚠️ Partial | ✅ | ❌ |
| **Free** | ✅ Always | ✅ | ✅ Free tier | ✅ |
| **No subscription** | ✅ | ✅ | ⚠️ Premium tier | ✅ |
| **Open source** | ✅ MIT | ✅ | ✅ | ✅ |
| **No telemetry** | ✅ Zero | ⚠️ | ⚠️ Limited | ❓ |
| **Voice input** | ✅ On-device | ❌ | ✅ | ❌ |
| **App size** | ✅ ~5MB | ~10MB | ~150MB | ~200MB |

---

## What is Ghostbar?

A macOS menu bar AI client that is **completely invisible to screen capture**.

Zoom, Google Meet, Microsoft Teams, OBS, QuickTime, Cmd+Shift+5 — none of them see it. It only exists on your physical display.

```swift
// The entire secret. One native AppKit API.
window.sharingType = .none
```

No hacks. No injection. A public, documented Apple API that removes the window from the display capture pipeline before any recording tool can touch it.

---

## Use cases

**Technical interviews**  
LeetCode, HackerRank, take-home assessments. Ask for hints, complexity analysis, edge cases — all while sharing your screen. The interviewer sees your code. They don't see Ghostbar.

**Live coding demos**  
Presenting to a client or team? Use AI to look up syntax, generate boilerplate, or sanity-check logic in real time. Nobody notices.

**Work calls & meetings**  
Prepare answers on the fly. Summarize what was just said. Draft a response before you speak.

**System design interviews**  
Ask for architecture patterns, trade-offs, scalability approaches instantly.

**Local & private**  
Pair with Ollama or LM Studio for fully on-device inference. Nothing leaves your machine.

---

## Tested invisible in ✅

| Tool | Status |
|---|---|
| Zoom | ✅ Invisible |
| Google Meet (Chrome) | ✅ Invisible |
| Microsoft Teams | ✅ Invisible |
| OBS Studio | ✅ Invisible |
| QuickTime screen recording | ✅ Invisible |
| macOS Cmd+Shift+5 | ✅ Invisible |

---

## Features

| | |
|---|---|
| 🫥 **Invisible by default** | Hidden from every screen capture tool on macOS |
| 🍎 **Menu bar only** | No Dock icon. No trace. Appears as **⬡** |
| 🤖 **Multi-backend** | Ollama, OpenAI, Claude, OpenRouter, NVIDIA NIM, LM Studio, llama.cpp |
| 🎙 **Voice input** | On-device transcription via whisper-cpp |
| 📸 **Screenshot analysis** | Capture your screen → attach to message. Model sees it, recorder doesn't. |
| 🔒 **Zero telemetry** | No analytics, no cloud, no tracking |
| ⚡ **Instant startup** | Native Swift — no Chromium, no Electron overhead |

---

## Install via Homebrew

```bash
brew tap rbc33/ghostbar
brew install --cask ghostbar
```

> **Note:** Ghostbar is not notarized. On first launch, right-click → Open → Open anyway.

---

## Install

**Option A — DMG (fastest)**

Download [`Ghostbar-v1.0.2.dmg`](https://github.com/rbc33/Ghostbar/releases), drag to Applications, open.

**Option B — Homebrew**

```bash
brew tap rbc33/ghostbar
brew install --cask ghostbar
```

**Option C — Build from source**

```bash
# Requirements: macOS 13+, Xcode Command Line Tools
xcode-select --install

git clone https://github.com/rbc33/Ghostbar.git && cd Ghostbar
bash build.sh
open Ghostbar.app
```

The **⬡** icon appears in your menu bar. Click → **Open chat**.

---

## How the invisibility works

macOS exposes a window-level API that controls whether a window participates in the display server's capture pipeline:

```swift
NSWindow.sharingType = .none     // excluded from all capture
NSWindow.sharingType = .readOnly // default — visible to recorders
```

Setting `.none` tells the macOS compositor to exclude the window from all capture operations before any recording application, screenshot tool, or API (`CGWindowListCreateImage`, `SCStreamConfiguration`, etc.) can observe it.

The window renders normally on your physical display. It simply does not exist to capture pipelines.

---

## Backends

Open **⬡ → Settings…** and pick your backend:

| Backend | URL | Notes |
|---|---|---|
| **Ollama** | `http://localhost:11434` | Local, no key |
| **OpenAI** | `https://api.openai.com/v1` | API key required |
| **Anthropic** | `https://api.anthropic.com/v1` | API key required |
| **OpenRouter** | `https://openrouter.ai/api/v1` | API key required |
| **NVIDIA NIM** | `https://integrate.api.nvidia.com/v1` | Free tier available |
| **LM Studio** | `http://localhost:1234/v1` | Local, no key |
| **llama.cpp** | `http://localhost:8080/v1` | Local, no key |

Any OpenAI-compatible server works — select **OpenAI** and set the URL.

### Free models via NVIDIA NIM

1. Go to [build.nvidia.com](https://build.nvidia.com) → sign in → any model → **Get API Key**
2. Key starts with `nvapi-`
3. In Ghostbar: select **NVIDIA NIM**, paste key

Hundreds of models (Llama, Mistral, Gemma, Qwen, DeepSeek) — no credit card required.

---

## Voice input

Ghostbar uses **Apple's native Speech Recognition** on-device by default — no extra downloads or terminal commands required.

Press **🎙** or **⌘⌥** → speak → press again → transcribed into the prompt. Fully on-device.

*(Optional)* If installed, `whisper.cpp` is also supported as an automatic fallback:
```bash
brew install whisper-cpp
mkdir -p /opt/homebrew/share/whisper-cpp
curl -L -o /opt/homebrew/share/whisper-cpp/ggml-base.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin
```

---

## Screenshot analysis

**⌘⇧** → captures screen → attaches to next message.

The model sees your screen. The screen recorder doesn't see Ghostbar.

Works with any vision model: `llava`, `gpt-4o`, `gemma3`, `claude-opus-4-7`…

---

## Keyboard shortcuts

Ghostbar is built to be 100% keyboard-navigable without touching the mouse:

| Action | Shortcut | Description |
|---|---|---|
| **Send prompt** | `Enter` or `⌘Enter` | Sends the prompt |
| **New line** | `Shift+Enter` | Inserts newline in prompt |
| **Prompt history** | `↑` / `↓` | Recall previous prompts (like terminal) |
| **Scroll chat up/down** | `PageUp` / `PageDown` | Smoothly scrolls chat messages (`Fn+↑` / `Fn+↓`) |
| **Scroll chat up/down** | `⌘[` / `⌘]` or `Ctrl+U` / `Ctrl+D` | Alternative keyboard scroll without leaving input |
| **Scroll to top / bottom** | `Home` / `End` | Jumps to start or end of chat (`Fn+←` / `Fn+→`) |
| **Focus prompt input** | `/` or `⌘L` | Jumps straight to input from anywhere |
| **Select model** | `⌘M` | Opens dropdown (navigate with `↑`/`↓`, `Enter` to select) |
| **Clear / New chat** | `⌘K` | Resets the conversation |
| **Stop AI response** | `Esc` or `⌘.` | Stops generating response |
| **Copy last response** | `⌘⇧C` | Copies last AI reply to clipboard |
| **Voice dictation** | `⌘⌥` | Toggles on-device voice recording |
| **Screenshot capture** | `⌘⇧` | Captures screen context |
| **Settings** | `⌘,` | Opens settings |
| **Hide / Close window** | `Esc` (when empty) or `⌘W` | Dismisses Ghostbar |
| **Toggle Ghostbar** | `⌘⌥M` | Global system hotkey to show/focus Ghostbar |

---

## Privacy

- **No telemetry.** No analytics. No crash reporting to any server.
- **No cloud.** Network calls go only to your configured backend.
- **Local backends** (Ollama, llama.cpp, LM Studio) run entirely on your machine — nothing leaves it.
- **Voice** transcription runs on-device via Whisper.
- **Screenshots** are sent only to your configured backend.

---

## Contributing

PRs welcome. Open an issue first for large changes.

```bash
git clone https://github.com/rbc33/Ghostbar.git
cd Ghostbar
open Package.swift   # Xcode opens automatically
```

---

<div align="center">

Made with ⬡ — because some things should stay invisible.

</div>