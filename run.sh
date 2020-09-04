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

# Lie #1: sudo is actually a call to su now.
function sudo {
  for arg do
    shift
    case \$arg in
      (--askpass|-A) : ;;
      (--validate|-v) set -- "\$@" "/bin/true" ;;
      (*) set -- "\$@" "\$arg" ;;
    esac
  done
  su "$adminuser" -c "/usr/bin/sudo --stdin \$*"
}
export -f sudo

# Lie #2: groups claims the user is an admin even if they are not.
function groups {
  echo "$admingroup \$(/usr/bin/groups \$*)"
}
export -f groups

# Lie #3: sudo --askpass is already set up.
touch \$HOME/fake-sudo-askpass
export SUDO_ASKPASS="\$HOME/fake-sudo-askpass"

# Make sure the user knows about their delusions
export PS1="\h:\W \u (\[\e[38;5;128;1m\]deluded\[\e[39;0m\])\$"

# Silence Mac deprecation warning on Bash
export BASH_SILENCE_DEPRECATION_WARNING=1
BASH
)"

set +e +u +o pipefail
/bin/bash --rcfile <(echo "$rcfile")
