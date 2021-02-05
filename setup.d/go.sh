#!/bin/bash

set -eux

if command -v go 1>/dev/null 2>&1; then
  ARCH=$(arch)
  # vscode-go dependencies
  echo "Getting dependencies for the vscode-go plugin "
  # via: https://github.com/golang/vscode-go/blob/master/.github/workflows/test-long.yml#L46-L60
  go version
  go get github.com/acroca/go-symbols
  go get github.com/davidrjenni/reftools/cmd/fillstruct
  go get github.com/haya14busa/goplay/cmd/goplay
  go get github.com/mdempsky/gocode
  go get github.com/sqs/goreturns
  go get github.com/uudashr/gopkgs/v2/cmd/gopkgs
  go get github.com/zmb3/gogetdoc
  go get golang.org/x/lint/golint
  go get golang.org/x/tools/cmd/gorename
  go get golang.org/x/tools/gopls
  go get github.com/cweill/gotests/...
  go get github.com/rogpeppe/godef
  go get github.com/ramya-rao-a/go-outline
  if [[ $ARCH != 'armv7' ]] && [[ $ARCH != 'armv6l' ]]; then
    go get github.com/go-delve/delve/cmd/dlv
  fi
fi
