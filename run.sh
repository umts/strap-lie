#!/bin/bash

set -euo pipefail

adminuser="$USER-d"
admingroup="admin"

until id -Gn "$adminuser" | grep "$admingroup"; do
  read -rp 'Enter your admin username: ' adminuser
done

function sudo {
  su "$adminuser" -c "sudo $*"
}

alias groups="echo -n '$admingroup ' && groups"
