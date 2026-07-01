#!/usr/bin/env bash
# Power menu via wmenu (Wayland dmenu). Lock uses swaylock-effects for the
# betterlockscreen-style blurred-screenshot lock (betterlockscreen itself is
# i3lock/X11 and cannot lock a Wayland session).

font='FiraCode Nerd Font 10'
lock_cmd=(swaylock -f --screenshot --effect-blur 7x5 --clock)

choice=$(printf '%s\n' \
  "  Lock" \
  "  Suspend" \
  "  Hibernate" \
  "  Logout" \
  "  Reboot" \
  "  Shutdown" \
  | wmenu -i -p "Power" -f "$font") || exit 0
[ -z "$choice" ] && exit 0

# Keep only the trailing keyword (drop the leading glyph + spaces).
action=${choice##* }

confirm() {
  [ "$(printf 'No\nYes\n' | wmenu -i -p "$1?" -f "$font")" = "Yes" ]
}

case "$action" in
  Lock)      exec "${lock_cmd[@]}" ;;
  Suspend)   exec systemctl suspend ;;
  Hibernate) confirm "Hibernate" && exec systemctl hibernate ;;
  Logout)    confirm "Log out"   && exec swaymsg exit ;;
  Reboot)    confirm "Reboot"    && exec systemctl reboot ;;
  Shutdown)  confirm "Shut down" && exec systemctl poweroff ;;
esac
