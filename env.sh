UNAME=$(uname -s)
HOSTNAME=$(hostname)
DOTFILES=$HOME/dotfiles
ENVD=$DOTFILES/env.d

export PATH=${HOME}/bin:${HOME}/local/bin:${DOTFILES}/bin:/usr/local/bin:/usr/local/sbin:$PATH
export EDITOR=vim

loadenv() {
  for f in $1/*.sh ; do
    if [ -f $f ]; then
      source $f
    fi
  done
  if [ "$SHELL" = '/bin/bash' ]; then
    for f in $1/*.bash ; do
      if [ -f $f ]; then
        source $f
      fi
    done
  fi
}

loadenv $ENVD
loadenv $ENVD/secret
if [ $UNAME = 'Darwin' ]; then
  loadenv $ENVD/darwin
fi
if [ $UNAME = 'Linux' ]; then
  loadenv $ENVD/darwin
fi
if [ $HOSTNAME = 'oglethorpe' ]; then
  loadenv $ENVD/dreamhost
fi
