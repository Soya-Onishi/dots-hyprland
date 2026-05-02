#!/usr/bin/env bash

SETUP_SCRIPT="$HOME/.config/hypr/custom/scripts/monitor-setup.sh"

# 自分自身の古いプロセスを終了（現在のPIDは除く）
# pkillが完了するのを少し待つ
# 自プロセスグループ以外の古いインスタンスを終了
for pid in $(pgrep -f "/.config/hypr/custom/scripts/monitor-watch.sh"); do
    if [ "$(ps -o pgid= -p $pid | tr -d ' ')" != "$(ps -o pgid= -p $$ | tr -d ' ')" ]; then
        kill "$pid"
    fi
done
sleep 1.5

handle() {
    case $1 in
        monitoradded*)   $SETUP_SCRIPT ;;
        monitorremoved*) $SETUP_SCRIPT ;;
    esac
}

$SETUP_SCRIPT
socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" \
    | while read -r line; do handle "$line"; done