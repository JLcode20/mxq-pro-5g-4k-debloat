@echo off
REM MXQ Pro 4K 5G (Allwinner H3) Debloat Script for Windows

echo ======================================================
echo     MXQ Pro 4K 5G (Allwinner H3) Debloat ^& Speedup
echo ======================================================
echo.

where adb >nul 2>nul
if %errorlevel% neq 0 (
    echo [!] ADB not found in PATH. Please install Android Platform Tools.
    pause
    exit /b 1
)

echo Checking for connected device...
adb get-state >nul 2>nul
if %errorlevel% neq 0 (
    set /p IP="Enter TV Box IP address (e.g. 192.168.1.80): "
    adb connect %IP%:5555
)

echo.
echo [1/3] Setting instant animation speeds...
adb shell "settings put global window_animation_scale 0.0"
adb shell "settings put global transition_animation_scale 0.0"
adb shell "settings put global animator_duration_scale 0.0"

echo.
echo [2/3] Disabling bloatware services...
adb shell "pm disable-user --user 0 com.factorytools.factorystability"
adb shell "pm disable-user --user 0 com.uv.droid.uota"
adb shell "pm disable-user --user 0 com.uv.droid.uotaback"
adb shell "pm disable-user --user 0 com.simple.appstore.flymarket"
adb shell "pm disable-user --user 0 com.example.android.autopair"
adb shell "pm disable-user --user 0 com.example.android.usbbt"
adb shell "pm disable-user --user 0 com.android.phone"
adb shell "pm disable-user --user 0 com.valor.mfc.droid.tvapp.generic"
adb shell "pm disable-user --user 0 com.mm.droid.livetv.tve"

echo.
echo [3/3] Optimizing ZRAM swap to 512 MB LZ4...
adb shell "swapoff /dev/block/zram0; echo 1 > /sys/block/zram0/reset; echo lz4 > /sys/block/zram0/comp_algorithm; echo 536870912 > /sys/block/zram0/disksize; mkswap /dev/block/zram0; swapon /dev/block/zram0; echo 100 > /proc/sys/vm/swappiness"

echo.
echo ======================================================
echo     Optimization Complete!
echo ======================================================
pause
