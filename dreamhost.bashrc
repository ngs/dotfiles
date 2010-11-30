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

PYTHONPATH=${MY_LOCAL}/python/site-packages

##
# Google Storage http://code.google.com/apis/storage/docs/gsutil.html
##
export GSUTIL_HOME=${MY_LOCAL}/gsutil
export BOTO_HOME=${GSUTIL_HOME}/boto
PATH=${PATH}:${GSUTIL_HOME}:${BOTO_HOME}/bin
PYTHONPATH=${PYTHONPATH}:${BOTO_HOME}

export PYTHONPATH
