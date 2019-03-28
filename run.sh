#!/bin/bash

set -euo pipefail

adminuser="$USER-d"
admingroup="admin"

if sudo -vn &>/dev/null; then
  exit 0
fi

until id -Gn "$adminuser" 2>/dev/null | grep "$admingroup" &>/dev/null; do
  read -rp 'Enter your admin username: ' adminuser
done

function sudo {
  su "$adminuser" -c "sudo $*"
}

alias groups="echo -n '$admingroup ' && groups"
