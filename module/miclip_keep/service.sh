#!/system/bin/sh
MODDIR=${0%/*}
KEY=mi_screen_shots_write_clipboard_enable
LOG=/data/adb/miclip_keep.log
INTERVAL=30

# wait for boot completed (works on KernelSU / APatch / Magisk)
until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 5; done
sleep 10

mkdir /dev/miclip_keep.lock 2>/dev/null || exit 0
(
  # cap log size (~64KB)
  [ -f $LOG ] && [ $(stat -c%s $LOG) -gt 65536 ] && tail -n 200 $LOG > $LOG.tmp && mv $LOG.tmp $LOG
  echo "$(date '+%F %T') watchdog started (module service.sh)" >> $LOG
  while true; do
    # stop if module disabled/removed in manager (takes effect without reboot)
    if [ -f $MODDIR/disable ] || [ -f $MODDIR/remove ]; then
      echo "$(date '+%F %T') module disabled/removed, watchdog exit" >> $LOG
      rmdir /dev/miclip_keep.lock 2>/dev/null
      exit 0
    fi
    CUR=$(settings get secure $KEY 2>/dev/null)
    if [ -n "$CUR" ] && [ "$CUR" != "1" ]; then
      settings put secure $KEY 1
      echo "$(date '+%F %T') $KEY was [$CUR], reset to 1" >> $LOG
    fi
    sleep $INTERVAL
  done
) </dev/null >/dev/null 2>&1 &
