export APPLE_SSH_ADD_BEHAVIOR=macos
[ -f ~/.ssh/id_rsa ] && ssh-add --apple-use-keychain ~/.ssh/id_rsa
[ -f ~/.ssh/id_ed25519 ] && ssh-add --apple-use-keychain ~/.ssh/id_ed25519
