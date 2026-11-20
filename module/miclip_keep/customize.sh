#!/system/bin/sh
SKIPUNZIP=0
settings put secure mi_screen_shots_write_clipboard_enable 1 2>/dev/null
ui_print "- screenshot-to-clipboard enabled"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/action.sh 0 0 0755
