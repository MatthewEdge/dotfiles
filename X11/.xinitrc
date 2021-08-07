urxvtd -o -q -f
xrdb -merge ~/.config/X11/.Xresources
xset r rate 200 40
exec i3
