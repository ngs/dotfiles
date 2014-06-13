if [ -d $HOME/.nodenv/bin ]; then
  export PATH=$HOME/.nodenv/bin:$PATH
  eval "$(nodenv init -)"
fi
