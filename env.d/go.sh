export CGO_CFLAGS="-I/usr/local/include"
export CGO_LDFLAGS="-L/usr/local/lib"
GOENV_ROOT="$HOME/.goenv"

if [ -d $GOENV_ROOT ]; then
  export GOENV_ROOT
  export PATH="$GOENV_ROOT/bin:$PATH"
  eval "$(goenv init -)"
fi
