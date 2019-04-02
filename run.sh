#!/bin/bash

set -euo pipefail

_adminuser="$USER-d"
_admingroup="admin"

# If sudo is already a function, chances are we're double-running.
[ "x$(type -t sudo)" = "xfunction" ] && exit 0

# If the user can aready sudo, that's fine.
if sudo -v -p 'Can you already sudo? Enter your password: '; then
  exit 0
fi

# We have to rely on group membership here, to avoid password-prompting.
until id -Gn "$_adminuser" 2>/dev/null | grep "$_admingroup" &>/dev/null; do
  read -rp 'Enter your admin username: ' _adminuser
done

# Lie #1: sudo us actually a call to su now.
function sudo {
  su "$_adminuser" -c "/usr/bin/sudo $*"
}
export -f sudo

# Lie #2: groups claims the user is an admin even if they're not.
function groups {
  echo "$_admingroup $(/usr/bin/groups $*)"
}
export -f groups

# These need to be exported in order to be used in the functions above
export _adminuser _admingroup

# Make sure the user knows about their delusions
/bin/bash --rcfile \
  <(grep -hs ^ /etc/bash.bashrc ~/.bashrc; echo 'PS1="\h:\W \u (\[\e[38;5;128;1m\]deluded\[\e[39;0m\])\$"')
