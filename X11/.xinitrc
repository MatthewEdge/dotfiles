urxvtd -o -q -f
xrdb -merge ~/.config/X11/.Xresources
xset r rate 200 30
exec i3
