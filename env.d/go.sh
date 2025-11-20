# Detect architecture and set appropriate paths
if [ "$(uname -m)" = "arm64" ]; then
  # Apple Silicon
  export CGO_CFLAGS="-I/opt/homebrew/include"
  export CGO_LDFLAGS="-L/opt/homebrew/lib"
else
  # Intel
  export CGO_CFLAGS="-I/usr/local/include"
  export CGO_LDFLAGS="-L/usr/local/lib"
fi
GOENV_ROOT="$HOME/.goenv"

if [ -d $GOENV_ROOT ]; then
  export GOENV_ROOT
  export PATH="$GOENV_ROOT/bin:$PATH"
  eval "$(goenv init -)"
  export PATH="$GOPATH/bin:$PATH"
fi
