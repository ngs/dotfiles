UNAME=$(uname -s)
HOSTNAME=$(hostname)
DOTFILES=$HOME/dotfiles
ENVD=$DOTFILES/env.d

export PATH=${HOME}/bin:${HOME}/local/bin:${DOTFILES}/bin:/usr/local/bin:/usr/local/sbin:$PATH
export EDITOR=vim

loadenv() {
  for f in $1/*.sh ; do
    if [ -f $f ] ; then
      source $f
    fi
  done
  if [ $BASH ]; then
    for f in $1/*.bash ; do
      if [ -f $f ] ; then
        source $f
      fi
    done
  fi
}

[ -f $ENVD/secret/env.sh   ] && loadenv $ENVD/secret
[ $UNAME    = 'Darwin'     ] && loadenv $ENVD/darwin
[ $UNAME    = 'Linux'      ] && loadenv $ENVD/linux
[ $HOSTNAME = 'oglethorpe' ] && loadenv $ENVD/dreamhost
loadenv $ENVD

