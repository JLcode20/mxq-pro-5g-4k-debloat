#!/usr/bin/env bash
#
# restore.sh - Re-enable previously disabled packages
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}======================================================${NC}"
echo -e "${CYAN}        MXQ Pro 4K 5G - Restore Disabled Apps         ${NC}"
echo -e "${CYAN}======================================================${NC}"

if ! adb get-state 1>/dev/null 2>&1; then
    echo -e "${RED}[!] ADB device not connected.${NC}"
    exit 1
fi

PACKAGES=(
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

for pkg in "${PACKAGES[@]}"; do
    echo -e "  [*] Enabling: $pkg"
    adb shell "pm enable $pkg" 2>/dev/null || true
done

echo -e "\n${YELLOW}[*] Restoring default animation scales (1.0x)...${NC}"
adb shell "settings put global window_animation_scale 1.0"
adb shell "settings put global transition_animation_scale 1.0"
adb shell "settings put global animator_duration_scale 1.0"

echo -e "\n${GREEN}[✔] Packages and animation scales restored to defaults.${NC}"
