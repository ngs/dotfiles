source "${HOME}/dotfiles/bashrc"

export PATH

alias ls='/bin/ls -G --color=auto'
alias ll='/bin/ls -lsG --color=auto'

export MY_LOCAL=${HOME}/local

export EDITOR=vim
export JAVA_HOME=/usr/local/dh/java
export LANG=en_US.UTF-8
export LD_LIBRARY_PATH=$MY_LOCAL/lib:$LD_LIBRARY_PATH
export PATH=$MY_LOCAL/bin:$PATH
export TZ=JST-9

export PYTHONPATH=${MY_LOCAL}/python/site-packages
