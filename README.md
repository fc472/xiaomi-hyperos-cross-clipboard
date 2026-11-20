# Xiaomi CN ROM: Cross-Device Clipboard for Phone, Tablet and PC

**English** | [繁體中文](README.zh-TW.md)

Two-way clipboard sharing (text and screenshots) between China-ROM HyperOS phones/tablets and a non-China Windows PC running Xiaomi Interconnect (小米互联服务), including pasting in any app via Gboard. Your Windows region setting does not need to be changed.

## Tested on

* Xiaomi 13 Pro, CN ROM (HyperOS 3)
* Xiaomi Pad 6S Pro, CN ROM
* Windows 11, Xiaomi Interconnect 2.0.4.577, milink 17.2.9.0

## Requirements

* Phone / tablet: root (KernelSU, APatch or Magisk) and LSPosed
* PC: Windows 10/11, Xiaomi Interconnect 2.0.4.577, administrator rights
* All devices on the same network (see notes)

## Downloads

Get these from [Releases](../../releases/latest) and check the SHA-256 in the release notes:

* `Patch-DistClipboard.ps1`: PC, lets the PC accept clipboard from tablets
* `miclip_keep_v3.zip`: phone / tablet root module, keeps "screenshot → clipboard" enabled
* `MiClipHook.apk`: phone / tablet LSPosed module, bypasses the region check and adds Gboard paste support

## Installation

**1. PC: patch Xiaomi Interconnect**

Skip this if you only use a phone. Open PowerShell as Administrator, `cd` to the script's folder and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\Patch-DistClipboard.ps1
```

Green text `Installed: DC128FB5...` means success. To undo, run it again with `-Rollback`.

**2. Phone / tablet: flash MiClip Keep**

Flash `miclip_keep_v3.zip` in KernelSU, APatch or Magisk.

**3. Phone / tablet: enable MiClipHook in LSPosed**

Install `MiClipHook.apk`, then LSPosed → Modules → MiClipHook → enable. Scope: check both `com.milink.service` and `com.miui.securitycenter`.

**4. Reboot**

Reboot the phone, the tablet and the PC.

Note: company, school and dorm Wi-Fi often blocks device discovery, so devices don't connect, or text syncs but screenshots don't. Use a hotspot from the PC or the phone instead.

When Xiaomi Interconnect updates itself, tablet → PC may stop working, because the script only supports 2.0.4.577. Phone ↔ PC is not affected.

## Other

* `pc/` contains the PC script, `module/miclip_keep/` the root module source.
* Not affiliated with Xiaomi. No Xiaomi files are redistributed; the script patches the copy already installed on your PC.
* License: [MIT](LICENSE). Modifying system components and using root is at your own risk.
