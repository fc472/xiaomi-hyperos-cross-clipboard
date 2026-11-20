# Xiaomi HyperOS Cross-Device Clipboard

**English** | [繁體中文](README.zh-TW.md)

Two-way clipboard sharing (text **and** screenshots) between **China-ROM HyperOS phones/tablets** and a **non-China Windows PC** running Xiaomi Interconnect (小米互联服务).

After setup, text and screenshots copied on any device can be pasted on the others, including inside third-party apps via **Gboard**. Your Windows region setting does **not** need to be changed.

> Tested on: Xiaomi 13 Pro (HyperOS 3, CN ROM), Xiaomi Pad 6S Pro (CN ROM), Windows 11 with Xiaomi Interconnect **2.0.4.577**, milink 17.2.9.0.
> Other keyboards than Gboard need extra changes in the hook module.

---

## Why it doesn't work out of the box

1. **The PC only accepts clipboard from phones.** Starting with Xiaomi Interconnect 2.0.4, the PC registers the clipboard service listener with a "phone only" device filter. Clipboard text and screenshots sent from a **tablet** are silently discarded. The opposite direction (PC → tablet) still works, which is why PC → tablet works while tablet → PC does not.
2. **Region checks on the phone/tablet.** The CN-ROM milink service refuses to sync with a PC whose region doesn't match. `MiClipHook` bypasses this check on the device side.
3. **Xiaomi Interconnect updates itself.** Every update replaces the patched file. The PC patch script only supports **2.0.4.577**. On any other version it stops without modifying anything, and you need to wait for a script targeting the new version.

---

## Requirements

| Side | Requirement |
|---|---|
| Phone / tablet | HyperOS (CN ROM), **root** (KernelSU / APatch / Magisk), **LSPosed** |
| PC | Windows 10/11, Xiaomi Interconnect **2.0.4.577**, administrator rights |
| Network | All devices on the same LAN that allows device discovery (see [Network notes](#network-notes)) |

## Downloads

Get the files from the [**Releases**](../../releases/latest) page:

| File | Where | Purpose |
|---|---|---|
| `Patch-DistClipboard.ps1` | PC | Lets the PC accept clipboard from tablets |
| `miclip_keep_v3.zip` | Phone / tablet | Root module that keeps "screenshot → clipboard" enabled |
| `MiClipHook.apk` | Phone / tablet | LSPosed module: region-check bypass, Gboard paste support, silent paste popup |

Check the SHA-256 values listed in the release notes before using the files.

---

## Installation

### Step 1 — PC: patch Xiaomi Interconnect (Administrator PowerShell)

Skip this step if you only use a phone (no tablet).

1. Open **Windows PowerShell as Administrator**.
2. `cd` to the folder that contains the script, e.g.
   ```powershell
   cd C:\Users\<you>\Downloads
   ```
3. Run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Patch-DistClipboard.ps1
   ```
4. Green text `Installed: DC128FB5...` means success.

What the script does:
- Locates the Xiaomi Interconnect install folder and checks that the version is 2.0.4.577.
- Verifies the SHA-256 of `dist_clipboard.dll` matches the original file (aborts otherwise).
- Backs up the original to `dist_clipboard.dll.orig`, patches 5 bytes, then verifies the result.
  If verification fails, it restores the original automatically.

To roll back:
```powershell
powershell -ExecutionPolicy Bypass -File .\Patch-DistClipboard.ps1 -Rollback
```

### Step 2 — Phone & tablet: flash MiClip Keep

Flash `miclip_keep_v3.zip` in KernelSU, APatch or Magisk manager.
On every boot it enables and guards the system setting `mi_screen_shots_write_clipboard_enable` (screenshot → clipboard).

Check status from the module's **Action** button in the root manager. The log is at `/data/adb/miclip_keep.log`.

### Step 3 — Phone & tablet: install MiClipHook and enable it in LSPosed

1. Install `MiClipHook.apk`.
2. Open **LSPosed → Modules → MiClipHook**, enable the module.
3. In the scope list, check **both** (usually pre-selected, but confirm):
   - `com.milink.service` (Xiaomi Interconnect / milink): region-check bypass, Gboard paste, silent popup
   - `com.miui.securitycenter` (Security): blocks writes that turn "screenshot → clipboard" off

If you later wipe your root environment or reinstall LSPosed, enable the module again.

### Step 4 — Reboot

Reboot the phone, the tablet **and** the PC.

---

## Network notes

Company, school and dorm Wi-Fi networks often block device discovery (mDNS / multicast) or enable client isolation (AP isolation). Typical symptoms:

- The PC app doesn't see your device, or keeps showing it as disconnected → neither text nor screenshots work.
- It connects and text syncs, but **screenshots fail**, because images use a separate Wi-Fi data channel that gets blocked.

Workaround: turn on a hotspot on the PC or the phone and connect the other devices to it (both tested).
If you use Windows Mobile Hotspot, note that it turns itself off when no device is connected, so check that it is on after a reboot.

## After Xiaomi Interconnect updates

If tablet → PC stops working again, check whether Xiaomi Interconnect is still version 2.0.4.577.
Phone ↔ PC is not affected by the PC patch.

---

## Repository layout

```
pc/Patch-DistClipboard.ps1     PC-side patch script (with -Rollback)
module/miclip_keep/            Source of the MiClip Keep root module
```

The module zip in Releases is built from `module/miclip_keep/` (zip the folder contents, with `META-INF` at the top level).

## Disclaimer

- This project is **not affiliated with Xiaomi**. It does not redistribute any Xiaomi files; the PC script patches the copy already installed on your own computer.
- Modifying system components and using root carries risk. You use this entirely at your own risk.

## License

[MIT](LICENSE)
