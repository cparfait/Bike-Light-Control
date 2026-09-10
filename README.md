<div align="center">

<img src="store/app-icon-500.png" width="120" alt="Bike Light Control">

# Bike Light Control

**Drive an iGPSPORT bike light from your Garmin Edge — while you ride.**

[![Connect IQ](https://img.shields.io/badge/Connect%20IQ-9.2.0-007cc3)](https://developer.garmin.com/connect-iq/)
[![Monkey C](https://img.shields.io/badge/Monkey%20C-Toybox%203.1%2B-5c4b8a)](https://developer.garmin.com/connect-iq/monkey-c/)
[![Edge models](https://img.shields.io/badge/Edge%20models-13-005f8c)](docs/compatibilite-edge.md)
[![Languages](https://img.shields.io/badge/languages-13-2e7d32)](#thirteen-languages-not-thirty-six)
[![Tests](https://img.shields.io/badge/unit%20tests-58-2e7d32)](app/source-test)
[![License](https://img.shields.io/badge/license-MIT-black)](LICENSE)

**English** · [Français](README.fr.md)

</div>

---

Your bike light and your bike computer sit ten centimetres apart on the same handlebar and
ignore each other. iGPSPORT ships a phone app to control the light; the phone is in your back
pocket. This project closes that gap: the Edge talks to the light directly over Bluetooth LE,
raises the beam when you pick up speed, drops it when you slow down, and turns everything off
when you stop the timer.

The Bluetooth protocol was not published by anyone. It was recovered by static analysis of the
iGPSPORT Android app, then **confirmed byte-for-byte against an HCI capture of the real light** —
the 19 distinct commands the vendor app emits are reproduced exactly. The full write-up lives in
[docs/protocole-vs1800s.md](docs/protocole-vs1800s.md).

## Scope, stated honestly

- **Developed and proven on a VS1800S, and on that model alone.** Nothing is hardcoded to it:
  the app asks the light for its type and its mode list, and adapts to the answer. The VS500,
  VS800, VS1200 and the TL30/TL50 tail lights therefore have a fair chance of working — but none
  has been tried. They are **unverified**, not supported.
- **Not a generic Bluetooth light driver.** The protocol is iGPSPORT's. A Varia, a Lezyne or any
  other brand will not even be detected — the scan filter looks for a Nordic UART service and a
  name starting with `VS…` or `TL…`.
- **One Edge has been ridden with it: the Edge 1050.** The other twelve compile, pass the test
  suite in the simulator and have their layout checked against the SDK profiles, but no one has
  put them on a handlebar yet. The Edge 830 is next — see
  [docs/essai-edge830.md](docs/essai-edge830.md).

## What it does

| | |
|---|---|
| 🔆 **Speed-based beam** | Brightness follows your speed, with adjustable thresholds and hysteresis so it does not flicker between modes at a steady pace. |
| 🔋 **Low-battery fallback** | Brightness is capped so the light survives to the end of the ride rather than dying at kilometre 40. |
| ⏱ **Off on stop, not on pause** | The light goes out when you stop the timer. A red light at the traffic light stays on. |
| 👆 **Manual override** | Tap the field to cycle modes, or open the full page to pick one. The next tap hands control back to the automation. |
| ▶️ **Search on demand** | The field looks for the light when you tap it, never on its own. On button-only models, the Lap button does the same, and an off-by-default setting can start the search with the timer. Either way the search is time-boxed: no light, no scan burning the battery for the whole ride. |
| 📈 **FIT recording** | Light level and light battery are written into the FIT file and show up in Garmin Connect. |
| 🎯 **Light identification** | With several lights around, the closest one is picked — and **blinks twice** to say so. An escape hatch moves to the next one. |
| 📱 **Companion app** | A control panel for use off-ride: turn the light on before you leave, set the light's own automations, check the summary tile. |
| 🌍 **13 languages** | Follows the language of the computer, no setting to find. |

## Two packages, one codebase

| | Data field | Device app |
|---|---|---|
| Name | **Bike Light Control** | **Bike Light Panel** |
| Runs | during the activity | off-ride, and on button-only Edges |
| Package | `dist/bike-light-control.iq` | `dist/bike-light-panel.iq` |
| Memory budget | 128 KB | 1 MB |
| Release size | 71–81 KB across the 13 targets | 82–94 KB |

Both share `shared/` — protocol, BLE layer, automation, control page — and move in lockstep
through a single [CHANGELOG.md](CHANGELOG.md).

## Compatible Edge models

**13 Edge models** expose the BLE central role to third-party apps. The list was established by
querying the API definitions in the locally installed SDK 9.2.0 profiles, not the online
documentation — method and details in [docs/compatibilite-edge.md](docs/compatibilite-edge.md):

> Edge 530 · 540 · 550 · 830 · 840 · 850 · 1030 · 1030 Plus · 1040 · **1050** ·
> Explore · Explore 2 · MTB

Excluded for lack of the API: Edge 130 / 130 Plus, 520, 520 Plus, 820, 1000 — and, the trap, the
**Edge 1030 Bontrager**, even though the plain Edge 1030 is compatible.

Two platform facts worth carrying around:

- **The compiler does not validate the BLE permission.** A data field declaring it compiles
  cleanly for an Edge 820 or an Edge 130. The `<iq:product>` list in the manifest has to be
  written by hand from the verified table.
- **Touch is not exposed in the SDK profiles.** It is a runtime property
  (`System.getDeviceSettings().isTouchScreen`), so `onTap()` handling is wired at runtime — one
  binary for all 13 models.

Memory is uniform across the 13 targets: 128 KB for a data field, 1 MB for an app. Code that
fits on a 1050 fits on a 530.

## Build

```bash
bash app/build.sh
```

Builds both binaries in release for the 13 targets. The script locates the JDK and the Connect
IQ SDK on its own. Other entry points: `edge1050` (one device), `debug`, `package` (store `.iq`
files).

```bash
bash app/build.sh test-all
```

Runs the 58 unit tests on **four profiles** — 530, MTB, 1040, 1050 — not just the 1050. Layout
tests walk all six screen formats whatever the profile, but the rest of the binary executes on
the simulator's: a suite that only ever runs on a 1050 proves nothing about the other twelve.
Use `bash app/build.sh test` for the 1050 alone.

Two checks cross-reference the code against the SDK profiles rather than the documentation:

```bash
python tools/check-icons.py
```

### Seeing the UI without a light

The simulator has no Bluetooth stack, so the app used to sit on "Searching" and
none of the control page could be seen. A demo build fills the lamp state with
what a real VS1800S declares:

```bash
bash app/build.sh sim
```

```bash
bash tools/sim-captures.sh
```

One PNG per screen format, in `captures/sim/`. It found four display defects on
its first run that no Edge 1050 could have shown — details in
[docs/application.md](docs/application.md).

```bash
python tools/i18n/langues-supportees.py --declarees
```

### Requirements

| | |
|---|---|
| Connect IQ SDK | 9.2.0, with the Edge device profiles |
| JDK | Temurin 21 LTS (11+ works) |
| Python | 3.x, for the tooling in `tools/` |
| Developer key | `developer_key.der` — personal, **never committed**, see `.gitignore` |

## Testing without a light

You do not need the lamp to exercise the whole chain. nRF Connect on Android can play a GATT
server: the Edge then connects to a fake VS1800S and scan, pairing, subscription, writes and
notifications all get validated. Step-by-step recipe in
[docs/essai-sans-lampe.md](docs/essai-sans-lampe.md).

## Thirteen languages, not thirty-six

English, French, German, Spanish, Italian, Portuguese, Dutch, Polish, Russian, Japanese, Korean,
Simplified and Traditional Chinese.

The SDK ties a font set to each **hardware part number**, and the 13 models add up to 18 of them:
the "ww" ones carry the European languages, the APAC ones carry Japanese, Korean and Chinese. No
language other than English is carried by all 18 — which is fine, a missing language falls back
to English.

What decides is size. Every declared language grows the binary whether or not it is usable on the
part number being compiled, and a data field gets 128 KB:

| Languages declared | Data field | App |
|---|---|---|
| 2 | 56,620 B | 61,372 B |
| **13** | **82,668 B** | **94,956 B** |
| 36 (all the SDK has) | 113,180 B | 134,284 B |

Measured on an Edge 1050 with the previous icon set — what matters here is the gap between rows,
which is down to languages alone. Thirty-six leaves nothing for the heap. The 13 kept are those
carried by at least 12 part numbers out of 18; the eight dropped — Arabic, Bulgarian, Estonian,
Latvian, Lithuanian, Romanian, Turkish, Ukrainian — are carried by exactly **one**.

## How the protocol works, in one paragraph

The light speaks **protobuf** (lite variant) over a Nordic UART BLE link, framed with a CRC-8.
The vendor app is not obfuscated on those classes, so the 43 lighting modes and their values, the
10 services, the 4 operations, the 22 automations and the complete message schema with field
numbers are all documented. There is no protobuf library for Connect IQ, so varint encoding is
written by hand in [shared/Protobuf.mc](shared/Protobuf.mc) — a few dozen lines. Full schema and
the seven points still to confirm on hardware: [docs/protocole-vs1800s.md](docs/protocole-vs1800s.md).

## Repository layout

```
shared/                             protocol, BLE layer, automation, control page
app/                                data field — "Bike Light Control"
  build.sh                          builds both binaries, runs tests, makes packages
  source/                           entry point, view, FIT recording
  source-test/                      58 unit tests
  resources/fit/                    FIT field declarations for Garmin Connect
  resources-icon-*/                 launcher icon, one per screen size (35–68 px)
widget/                             device app — "Bike Light Panel"
store/                              500×500 store icons and the store listing copy
docs/
  protocole-vs1800s.md              the protocol — Phase 1 deliverable
  compatibilite-edge.md             compatible Edge models, verified against the SDK
  application.md                    app architecture and design decisions
  essai-sans-lampe.md               testing with a fake light (nRF Connect)
  essai-edge830.md                  field-test sheet for the Edge 830
  essai-modeles.md                  the 13 models — generated from the SDK profiles
  audit-publication.md              store-publishability audit
  phase1-procedure-capture-ble.md   BLE capture procedure + Wireshark method
  phase1-journal-capture.md         log sheet to fill in during the capture
tools/
  check-icons.py                    icons cross-checked against the SDK profiles
  fiche-modeles.py                  writes docs/essai-modeles.md from the SDK profiles
  i18n/                             translations: one JSON table per language
  make-icons.py                     draws the launcher and store icons
  deploy-edge.sh                    installs both binaries on a USB-connected Edge
  pull-btsnoop.sh                   pulls the HCI log off the phone
  scan-apk.py, dump-proto-*.py      APK analysis, without Java
captures/                           analysis reports (raw logs and APKs stay out — .gitignore)
```

## Status

| | |
|---|---|
| BLE protocol | ✅ complete schema, confirmed by HCI capture |
| Monkey C implementation | ✅ 58 tests, 12 of them on real captured bytes |
| Build for 13 targets | ✅ within budget, 13 languages included |
| Edge 1050, on the device | ✅ connection and control working — data field, app and glance validated |
| UI | ✅ layout verified on all 6 screen formats |
| Edge 830 and the other 11 | 🟡 not yet tried on hardware |
| Reconnection after the light sleeps | 🟡 fixed in code, not yet observed on hardware |
| Connect IQ Store | 🟡 blockers cleared → [docs/audit-publication.md](docs/audit-publication.md) |

## References

- [`Toybox.BluetoothLowEnergy`](https://developer.garmin.com/connect-iq/api-docs/Toybox/BluetoothLowEnergy.html) ·
  [`BleDelegate`](https://developer.garmin.com/connect-iq/api-docs/Toybox/BluetoothLowEnergy/BleDelegate.html)
- [Connect IQ — Device Reference](https://developer.garmin.com/connect-iq/device-reference/)
- [VS1800S — iGPSPORT product page](https://www.igpsport.com/product/vs1800s)
- [Reverse Engineering BLE Devices](https://reverse-engineering-ble-devices.readthedocs.io/en/latest/protocol_reveng/00_protocol_reveng.html) ·
  [Domyos EL500 GATT teardown](https://jcjc-dev.com/2023/03/19/reversing-domyos-el500-elliptical/) ·
  [Reverse Engineering Cheap BLE Devices](https://www.alexwhittemore.com/reverse-engineering-cheap-ble-devices/)

## License

[MIT](LICENSE), with a reservation on trademarks and on `captures/`. Not affiliated with, nor
endorsed by, Garmin or iGPSPORT. "Garmin", "Edge", "Connect IQ" and "iGPSPORT" belong to their
respective owners.
