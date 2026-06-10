# Headset Control Plasmoid

A KDE Plasma 6 system tray widget for [HeadsetControl](https://github.com/Sapd/HeadsetControl) that shows headset battery level, sidetone, ChatMix balance, and EQ presets.

## Features

- **Battery** — live level with color-coded status (green/yellow/red) and charging indicator
- **Sidetone** — slider to adjust mic monitoring volume (shown when supported)
- **ChatMix** — bidirectional balance bar showing game/chat mix offset (shown when supported)
- **EQ Presets** — buttons for Flat, Bass Boost, Smiley, and Focus presets (shown when supported)

Features are shown or hidden automatically based on what the connected headset supports.

## Requirements

- KDE Plasma 6
- [`headsetcontrol`](https://github.com/Sapd/HeadsetControl) installed at `/usr/local/bin/headsetcontrol`

## Installation

```bash
kpackagetool6 --install . --type Plasma/Applet
```

Or to update an existing install:

```bash
kpackagetool6 --upgrade . --type Plasma/Applet
```

Then add **Headset Control** from the system tray widget list.

## Configuration

| Setting      | Default | Description                        |
|--------------|---------|------------------------------------|
| Polling Rate | 5000 ms | How often to query `headsetcontrol` |

## Widget ID

`us.willkill.headsetcontrol`

## Remotes

Mirrored to two remotes. To replicate the setup:

```bash
git remote add forgejo ssh://git@git.willkill.us:9028/wintermute/headsetcontrol-plasmoid.git
git remote set-url --add --push origin git@github.com:villa-straylight/headsetcontrol-plasmoid.git
git remote set-url --add --push origin ssh://git@git.willkill.us:9028/wintermute/headsetcontrol-plasmoid.git
```

`git push` will then push to both GitHub and Forgejo simultaneously.
