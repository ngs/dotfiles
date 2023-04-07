#!/bin/sh

set -eu

EDITOR=com.panic.Nova

UTIS="
  public.yaml
  public.make-source
  public.unix-executable
  public.json
  public.text
  public.data
  public.item
  public.content
  public.source-code
  public.script
  public.ruby-script
  com.netscape.javascript-source
  org.golang.golang
"

EXTS="
  css
  go
  gql
  graphql
  graphqls
  js
  json
  jsx
  lock
  md
  py
  rb
  sass
  scss
  sh
  sql
  svg
  toml
  ts
  tsx
  txt
  xml
  yaml
  yml
"

for I in $UTIS; do
  duti -s $EDITOR $I all
done

for I in $EXTS; do
  # duti -s com.panic.Nova .sh all
  duti -s $EDITOR ".$I" all
done
