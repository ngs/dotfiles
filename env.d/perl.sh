export PERL_AUTOINSTALL="--alldeps"
export COPY_EXTENDED_ATTRIBUTES_DISABLE=1

if [ -d $HOME/.plenv ]; then
  export PATH=$HOME/.plenv/shims:$PATH
  eval "$(plenv init -)"
fi

