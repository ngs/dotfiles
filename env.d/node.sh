if [ -d $HOME/.nodenv/bin ]; then
  export PATH=$HOME/.nodenv/bin:$PATH
  eval "$(nodenv init -)"
fi

if [ -d $HOME/.nodenv/shims ]; then
  export PATH=$HOME/.nodenv/shims:$PATH
  eval "$(nodenv init -)"
fi
