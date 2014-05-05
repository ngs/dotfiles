alias apk2emulator='ant debug && adb -s emulator-5554 install -r bin/*-debug.apk'
alias apk2device1='ant debug && adb -s CB511J9139 install -r bin/*-debug.apk'
alias apk2device2='ant debug && adb -s HT963LF01318 install -r bin/*-debug.apk'

alias logcat-emulator='adb -s emulator-5554 logcat'
alias logcat-device1='adb -s CB511J9139 logcat'
alias logcat-device2='adb -s HT963LF01318 logcat'

alias svn-add-all="svn st | grep ^? | cut -d ' ' -f 8 | xargs svn add"

alias setlang-en='defaults write NSGlobalDomain AppleLanguages "(en,ja,zh-Hans,zh-Hant)"'
alias setlang-ja='defaults write NSGlobalDomain AppleLanguages "(ja,en,zh-Hans,zh-Hant)"'

alias md=mkdir
alias rd=rmdir
alias ll='ls -ls'

alias count="ls -l | wc"
alias screenls="screen -ls"
alias screenx="screen -x"
alias screenr="screen -r"

# alias tmux='SHELL=zsh tmux -2'
alias tmuxls="tmux list-sessions"
alias tmuxa="tmux attach"
alias tmux="tmux -2"
