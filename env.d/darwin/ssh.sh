# Keep SSH_AUTH_SOCK pointing at a socket that is actually alive.
#
# macOS hands every login session its own agent socket under
# /var/run/com.apple.launchd.*/Listeners, and the path changes with the session.
# A shell that outlives the session it was started from — a tmux pane reattached
# from a client that has since gone away is the usual one — keeps the old path,
# and from then on every ssh-add fails with:
#
#     Error connecting to agent: No such file or directory
#
# launchctl cannot help (`launchctl getenv SSH_AUTH_SOCK` is empty; the value is
# injected into the session bootstrap, not the launchd environment). So point
# SSH_AUTH_SOCK at a stable symlink instead, and re-aim that symlink at the live
# socket on every new login shell. Long-lived shells hold the symlink path, so
# they start working again the moment any fresh terminal refreshes it.
__ssh_agent_sock="$HOME/.ssh/agent.sock"

# Only re-aim the link from a local session. Inside an inbound ssh connection
# SSH_AUTH_SOCK is a forwarded socket that dies with that connection, and
# pointing the link at it would break every other shell on this Mac.
if [ -z "${SSH_CONNECTION:-}" ] &&
  [ -S "${SSH_AUTH_SOCK:-}" ] &&
  [ "${SSH_AUTH_SOCK:-}" != "$__ssh_agent_sock" ]; then
  ln -sfn "$SSH_AUTH_SOCK" "$__ssh_agent_sock"
fi

# -S follows the link, so this is false while the target is dead — in which case
# leave whatever we inherited alone rather than swapping in a known-bad path.
if [ -S "$__ssh_agent_sock" ]; then
  export SSH_AUTH_SOCK="$__ssh_agent_sock"
fi

unset __ssh_agent_sock
