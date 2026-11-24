# Headset Control Plasmoid

A KDE Plasma 6 system tray widget that shows your headset's battery level, sidetone, ChatMix balance and EQ
presets. It is a front end for [HeadsetControl](https://github.com/Sapd/HeadsetControl): the widget does not talk
to the headset itself, it runs the `headsetcontrol` command and shows what it reports.

## Features

- **Battery**: live level in the tray, colour-coded (green ≥ 50 %, yellow ≥ 20 %, red below), with a charging
  indicator and a progress bar in the popup.
- **Sidetone**: slider (0–128) for mic monitoring volume.
- **ChatMix**: game/chat balance bar, read from the headset's ChatMix dial (display only).
- **EQ presets**: Flat, Bass Boost, Smiley and Focus buttons.

Each section appears only when the connected headset reports that capability.

## Requirements

- KDE Plasma 6 (uses the Plasma 6 applet API and `org.kde.plasma.plasma5support`).
- **HeadsetControl**, with `headsetcontrol` on Plasma's `PATH` (`/usr/bin` or `/usr/local/bin` both work).
- A headset that HeadsetControl supports. See its
  [supported devices list](https://github.com/Sapd/HeadsetControl#supported-headsets).

## Installing HeadsetControl

The widget does nothing without HeadsetControl. Install it first and check that it can see your headset.

### Option A: distro package (recommended)

Most distros package HeadsetControl, for example Fedora (`sudo dnf install headsetcontrol`), the upstream
Ubuntu/Debian PPA, the AUR, NixOS and FreeBSD. The upstream README has the
[full list](https://github.com/Sapd/HeadsetControl#installation).

### Option B: build from source

For a newer version than your distro ships. It installs to `/usr/local/bin`, which comes before `/usr/bin` on
`PATH`, so it takes priority over a package. `make install` also installs the udev rules that let a normal user
talk to the headset.

```bash
sudo dnf install cmake gcc hidapi-devel git          # Fedora; use your distro's equivalents
git clone https://github.com/Sapd/HeadsetControl && cd HeadsetControl
mkdir build && cd build && cmake .. && make && sudo make install
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### Check it works

Unplug and replug the headset's dongle after installing the udev rules, then run as your normal user (not root):

```bash
headsetcontrol -b -o json
```

You should see a JSON block with `"status": "success"`, your headset's name and a `battery` section. If this does
not work, the widget won't either; see [Troubleshooting](#troubleshooting).

## Installing the widget

From a clone of this repo:

```bash
kpackagetool6 --type Plasma/Applet --install .
```

To update an existing install after pulling changes:

```bash
kpackagetool6 --type Plasma/Applet --upgrade .
```

Then right-click the system tray → **Configure System Tray…** → **Entries**, and set **Headset Control** to
*Shown* (or *Shown when relevant*). It can also be added to a panel or the desktop as a normal widget.

To remove it:

```bash
kpackagetool6 --type Plasma/Applet --remove us.willkill.headsetcontrol
```

## Using it

The tray shows a headset icon and a short status:

| Tray label | Meaning |
| --- | --- |
| `NN%` | Battery level |
| `⚡` | Charging |
| `off` | Headset found but battery not available (usually the headset is switched off and only the dongle is in) |
| `–` | No headset found, or `headsetcontrol` failed or isn't installed |

Click it to open the popup with the device name, battery, sidetone slider, ChatMix bar and EQ buttons.

- **Sidetone**: drag and release; the value is sent on release. HeadsetControl can't read the current sidetone
  back from the headset, so the slider starts at 16 each time Plasma starts, not at the headset's real value.
- **ChatMix**: 64 is balanced; lower leans to game audio, higher to chat. It follows the dial on the headset.

## Configuration

| Setting | Default | Description |
| --- | --- | --- |
| `pollingRate` | 5000 ms | How often the widget runs `headsetcontrol -b -o json` |

The package has no settings page yet, so the setting can only be changed by editing it in the Plasma config
and restarting Plasma. In `~/.config/plasma-org.kde.plasma.desktop-appletsrc`, find the
`[Containments][N][Applets][M]` section with `plugin=us.willkill.headsetcontrol`, and add `pollingRate=<ms>` under
a `[Containments][N][Applets][M][Configuration][General]` group, using the same N and M.

## Troubleshooting

- **Tray shows `–`**: run `headsetcontrol -b -o json` as your user.
  - `command not found`: HeadsetControl isn't installed; see [Installing HeadsetControl](#installing-headsetcontrol).
  - It works with `sudo` but not without: the udev rules are missing or not applied. Reload them
    (`sudo udevadm control --reload-rules && sudo udevadm trigger`) and replug the dongle.
  - It runs but lists no devices: your HeadsetControl version doesn't support the headset; try a newer one.
- **Tray shows `off`**: the dongle is connected but the headset is off or out of range.
- **A section is missing**: your headset doesn't report that capability. `headsetcontrol -o json` lists them under
  `capabilities`.
- **Changes to the widget don't show up**: after `--upgrade`, restart Plasma
  (`systemctl --user restart plasma-plasmashell`).

## Known issues

- EQ buttons always offer the same four presets (indices 0–3), whatever the headset reports.
- Only the first device HeadsetControl reports is shown.

## Development

How the widget works, its files and how to test changes: [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Widget ID

`us.willkill.headsetcontrol`

## Repository

- Home: <https://github.com/voidgrid/voidgrid-hc-plasmoid> (`origin`)
- Mirror: Forgejo, `ssh://git@git.willkill.us:9028/wintermute/headsetcontrol-plasmoid.git` (`forgejo`)
