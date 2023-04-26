#!/bin/bash

set -eux

if command -v go 1>/dev/null 2>&1; then
  ARCH=$(arch)
  # vscode-go dependencies
  echo "Getting dependencies for the vscode-go plugin "
  # via: https://github.com/golang/vscode-go/blob/master/.github/workflows/test-long.yml#L46-L60
  go version
  go install github.com/acroca/go-symbols@latest
  go install github.com/davidrjenni/reftools/cmd/fillstruct@latest
  go install github.com/haya14busa/goplay/cmd/goplay@latest
  go install github.com/mdempsky/gocode@latest
  go install github.com/sqs/goreturns@latest
  go install github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest
  go install github.com/zmb3/gogetdoc@latest
  go install golang.org/x/lint/golint@latest
  go install golang.org/x/tools/cmd/gorename@latest
  go install golang.org/x/tools/gopls@latest
  go install github.com/cweill/gotests/...@latest
  go install github.com/rogpeppe/godef@latest
  go install github.com/ramya-rao-a/go-outline@latest
  if [ $ARCH != 'armv7' ] && [ $ARCH != 'armv6l' ]; then
    go install github.com/go-delve/delve/cmd/dlv@latest
  fi
fi
