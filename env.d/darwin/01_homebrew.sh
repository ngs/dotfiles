if [ -e /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  LDFLAGS+=" -L$(brew --prefix)/lib "
  export LDFLAGS
fi
