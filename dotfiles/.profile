xset r rate 200 40
xsetroot -solid "#000000"
setxkbmap -layout us,ru -option grp:alt_caps_toggle

# Including generated profile (if available)
[ -r ${HOME}/.profile-gen ] && . ${HOME}/.profile-gen
