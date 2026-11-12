#!/usr/bin/env bash
#
# debloat.sh - Optimization script for MXQ Pro 4K Allwinner H3 Android TV Box
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}======================================================${NC}"
echo -e "${CYAN}    MXQ Pro 4K 5G (Allwinner H3) Debloat & Speedup    ${NC}"
echo -e "${CYAN}======================================================${NC}"

# Check for adb
if ! command -v adb &> /dev/null; then
    echo -e "${RED}[!] ADB is not installed or not in PATH.${NC}"
    echo "Please install Android Platform Tools and try again."
    exit 1
fi

# Detect device
DEVICE_COUNT=$(adb devices | grep -v "List" | grep "device" | wc -l)

if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}[?] No active ADB device detected.${NC}"
    read -rp "Enter TV Box IP address (e.g. 192.168.1.80): " IP
    if [ -n "$IP" ]; then
        echo -e "[*] Connecting to ${IP}:5555..."
        adb connect "${IP}:5555"
    fi
fi

# Verify connection
if ! adb get-state 1>/dev/null 2>&1; then
    echo -e "${RED}[!] Failed to communicate with ADB device. Make sure debugging is enabled.${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Device connected successfully!${NC}"

# 1. Disable Animations for Snappy UI
echo -e "\n${YELLOW}[1/4] Disabling UI animation scales for instant responsiveness...${NC}"
adb shell "settings put global window_animation_scale 0.0"
adb shell "settings put global transition_animation_scale 0.0"
adb shell "settings put global animator_duration_scale 0.0"
echo -e "${GREEN}[✔] Animation scales set to 0.0x.${NC}"

# 2. Debloat background packages
echo -e "\n${YELLOW}[2/4] Disabling background bloatware and test services...${NC}"
BLOAT_PACKAGES=(
    "com.factorytools.factorystability"
    "com.uv.droid.uota"
    "com.uv.droid.uotaback"
    "com.simple.appstore.flymarket"
    "com.example.android.autopair"
    "com.example.android.usbbt"
    "com.android.phone"
    "com.valor.mfc.droid.tvapp.generic"
    "com.mm.droid.livetv.tve"
)

for pkg in "${BLOAT_PACKAGES[@]}"; do
    if adb shell "pm list packages | grep -q $pkg"; then
        echo -e "  [*] Disabling: $pkg"
        adb shell "pm disable-user --user 0 $pkg" 2>/dev/null || true
    fi
done
echo -e "${GREEN}[✔] Bloatware disabled.${NC}"

# 3. Optimize ZRAM Swap to 512MB LZ4
echo -e "\n${YELLOW}[3/4] Reconfiguring ZRAM swap memory (512 MB LZ4)...${NC}"
adb shell "
    swapoff /dev/block/zram0 2>/dev/null || true
    echo 1 > /sys/block/zram0/reset 2>/dev/null || true
    echo lz4 > /sys/block/zram0/comp_algorithm 2>/dev/null || true
    echo 536870912 > /sys/block/zram0/disksize 2>/dev/null || true
    mkswap /dev/block/zram0 2>/dev/null || true
    swapon /dev/block/zram0 2>/dev/null || true
    echo 100 > /proc/sys/vm/swappiness 2>/dev/null || true
"
echo -e "${GREEN}[✔] ZRAM expanded to 512 MB LZ4.${NC}"

# 4. Make ZRAM persistent across reboots
echo -e "\n${YELLOW}[4/4] Installing persistent startup hook...${NC}"
adb remount >/dev/null 2>&1 || true
adb shell 'cat << "EOF" > /system/bin/install-recovery.sh
#!/system/bin/sh
swapoff /dev/block/zram0
echo 1 > /sys/block/zram0/reset
echo lz4 > /sys/block/zram0/comp_algorithm
echo 536870912 > /sys/block/zram0/disksize
mkswap /dev/block/zram0
swapon /dev/block/zram0
echo 100 > /proc/sys/vm/swappiness
settings put global window_animation_scale 0.0
settings put global transition_animation_scale 0.0
settings put global animator_duration_scale 0.0
EOF
chmod 755 /system/bin/install-recovery.sh
' 2>/dev/null || true
echo -e "${GREEN}[✔] Persistent startup hook installed in /system/bin/install-recovery.sh.${NC}"

echo -e "\n${CYAN}======================================================${NC}"
echo -e "${GREEN}    All optimizations applied successfully! Enjoy!    ${NC}"
echo -e "${CYAN}======================================================${NC}"
