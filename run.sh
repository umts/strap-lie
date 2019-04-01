#!/bin/bash

set -euo pipefail

adminuser="$USER-d"
admingroup="admin"

# If sudo is already a function, chances are we're double-running.
[ "x$(type -t sudo)" = "xfunction" ] && exit 0

# If the user can aready sudo, that's fine.
if (sudo -vn && sudo -ln) 2>&1 | grep -v 'may not' > /dev/null; then
  exit 0
fi

# We have to rely on group membership here, to avoid password-prompting.
until id -Gn "$adminuser" 2>/dev/null | grep "$admingroup" &>/dev/null; do
  read -rp 'Enter your admin username: ' adminuser
done

# Lie #1: sudo us actually a call to su now.
function sudo {
  su "$adminuser" -c "sudo $*"
}

# Lie #2: groups claims the user is an admin even if they're not.
alias groups="echo -n '$admingroup ' && groups"
