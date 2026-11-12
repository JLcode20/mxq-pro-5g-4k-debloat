# MXQ Pro 4K 5G (Allwinner H3) Debloat & Performance Optimization Suite

A comprehensive toolkit to debloat, optimize memory, and fix sluggish performance on generic **MXQ Pro 4K 5G** Android TV boxes powered by the **Allwinner H3** SoC (`dolphin_fvd_p1` / `sun8iw7p1`).

---

## 🔍 The Reality of "MXQ Pro 4K 5G"

These generic budget TV boxes are notorious for marketing spoofing:

| Feature / Spec | Advertised Box Label | Actual Hardware Reality |
| :--- | :--- | :--- |
| **SoC** | "64-bit Quad/Octa-Core" | **Allwinner H3 (32-bit quad-core ARM Cortex-A7 @ 1.0–1.2 GHz)** |
| **GPU** | "4K Mali GPU" | **ARM Mali-400 MP2 (struggles with heavy 4K UI rendering)** |
| **RAM** | "4 GB / 8 GB / 16 GB" | **1 GB (often 512 MB, with ~3.2 GB kernel dummy padding)** |
| **Android OS** | "Android 10.1 / 11 / 12" | **Android 7.1.2 Nougat (`NRD91N`) with spoofed build strings** |
| **Frame Buffer** | "4K Ultra HD" | **1280x720 (720p)** |
| **Default Swap** | Often misconfigured | **128 MB ZRAM (nearly 90% full at idle)** |

Because of the tiny 1 GB RAM and aggressive background services (factory stress testers, fake OTA scrapers, telephony daemons), the system constantly stutters, freezes, and drops frames.

---

## ⚡ What These Scripts Do

1. **Eliminate UI Lag & Animation Delays:**
   - Sets Window, Transition, and Animator animation scales to `0.0`. Menu scrolling and app launching become instantaneous without loading the Mali-400 GPU.

2. **Debloat Dangerous & Wasteful Background Services:**
   - `com.factorytools.factorystability` (Factory burn-in stress tester left running)
   - `com.uv.droid.uota` & `uotaback` (Fake background OTA updater/adware)
   - `com.simple.appstore.flymarket` (Rogue third-party ad market)
   - `com.example.android.autopair` & `usbbt` (Unfinished dev/test daemons)
   - `com.android.phone` (Cellular telephony stack running on a TV box with no SIM slot)
   - `com.valor.mfc.droid.tvapp.generic` & `com.mm.droid.livetv.tve` (Bloatware background streaming services)

3. **Quadruple ZRAM Swap (128 MB ➔ 512 MB LZ4):**
   - Expands compressed swap memory from 128 MB to 512 MB using the high-speed **LZ4** algorithm and optimizes kernel swappiness.
   - Prevents Out-Of-Memory (OOM) app crashes and UI freezing during streaming.
   - Installs a persistent startup hook into `/system/bin/install-recovery.sh` so optimizations persist across reboots.

4. **Reduce Thermal Throttling:**
   - Drops idle CPU temperatures by ~5°C–10°C simply by eliminating rogue background CPU polling loops.

---

## 🚀 Quick Start

### 1. Enable ADB on the TV Box
Most Allwinner H3 boxes have network ADB available:
- **Option A (Wi-Fi):** If port 5555 is not open, install **WiFi ADB** or **Terminal Emulator** APK on the box. In Terminal, run:
  ```sh
  su
  setprop service.adb.tcp.port 5555
  stop adbd
  start adbd
  ```
- **Option B (USB):** Connect a USB data cable from your PC to the box's **OTG port** (usually USB-4 or USB-1).

### 2. Connect via ADB from your PC
Find the TV box's IP address under **Settings > Network / Wi-Fi** (e.g. `192.168.1.80`):
```bash
adb connect <TV_BOX_IP>:5555
adb devices
```

### 3. Run the Optimization Script

**On Linux / macOS:**
```bash
chmod +x debloat.sh
./debloat.sh
```

**On Windows:**
Double-click `debloat.bat` or run it from Command Prompt / PowerShell.

---

## 🔄 Reverting Changes
If you ever need to restore any disabled package:
```bash
chmod +x restore.sh
./restore.sh
```

---

## 💡 Recommended Additional Tweaks

1. **Lightweight Launcher:** Replace the stock launcher with [FLauncher](https://gitlab.com/undate/flauncher) or **ATV Launcher**.
2. **YouTube Alternative:** Install **SmartTube** (SmartTubeNext). Force video format to AVC/H.264 (hardware-decoded by H3) for silky-smooth 1080p playback without ads.
3. **Hardware Cooling:** Add a small adhesive aluminum/copper heatsink to the H3 chip or place a 5V USB fan under the chassis to prevent 85°C thermal throttling.

---

## 📄 License
MIT License. Free to use, modify, and share.
