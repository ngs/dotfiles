#!/bin/sh

set -eu

EDITOR=com.panic.Nova

UTIS="
  public.yaml
  public.mpeg-2-transport-stream
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

for I in $UTIS; do
  duti -s $EDITOR $I all
done
