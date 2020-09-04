#!/bin/bash

set -euo pipefail

adminuser="$USER-d"
admingroup="admin"

# If sudo is already a function, chances are we're double-running.
[ "x$(type -t sudo)" = "xfunction" ] && exit 0

# If the user can aready sudo, that's fine.
if sudo -v -p 'Can you already sudo? Enter your password: '; then
  exit 0
fi

# We have to rely on group membership here, to avoid password-prompting.
until id -Gn "$adminuser" 2>/dev/null | grep "$admingroup" &>/dev/null; do
  read -rp 'Enter your admin username: ' adminuser
done

rcfile="$(cat <<BASH
#!/bin/bash

# Lie #1: sudo us actually a call to su now.
function sudo {
  su "$adminuser" -c "/usr/bin/sudo \$*"
}

# Lie #2: groups claims the user is an admin even if they're not.
function groups {
  echo "$admingroup \$(/usr/bin/groups \$*)"
}

# Make sure the user knows about their delusions
export PS1="\h:\W \u (\[\e[38;5;128;1m\]deluded\[\e[39;0m\])\$"
BASH
)"

set +e +u +o pipefail
/bin/bash --rcfile <(echo "$rcfile")
