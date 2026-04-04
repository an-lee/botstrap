# Adds the botstrap checkout bin directory to PATH (see ~/.config/botstrap/env.sh).
if [[ -f "${HOME}/.config/botstrap/env.sh" ]]; then
  # shellcheck disable=SC1091
  . "${HOME}/.config/botstrap/env.sh"
fi
