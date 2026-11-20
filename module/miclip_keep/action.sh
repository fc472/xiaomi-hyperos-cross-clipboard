#!/system/bin/sh
KEY=mi_screen_shots_write_clipboard_enable
echo "$KEY = $(settings get secure $KEY)"
if [ -d /dev/miclip_keep.lock ]; then echo "watchdog: running"; else echo "watchdog: NOT running"; fi
tail -n 5 /data/adb/miclip_keep.log 2>/dev/null
