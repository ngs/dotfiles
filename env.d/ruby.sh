if [ -d $HOME/.rubyenv/bin ]; then
  export PATH=$HOME/.rubyenv/bin:$PATH
  eval "$(rbenv init -)"
fi
