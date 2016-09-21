_homebrew-installed() {
  type brew &> /dev/null
}

_nodenv-from-homebrew-installed() {
  brew --prefix nodenv &> /dev/null
}

FOUND_NODENV=0
nodenvdirs=("$HOME/.nodenv" "/usr/local/nodenv" "/opt/nodenv" "/usr/local/opt/nodenv")
if _homebrew-installed && _nodenv-from-homebrew-installed ; then
    nodenvdirs=($(brew --prefix nodenv) "${nodenvdirs[@]}")
fi

for nodenvdir in "${nodenvdirs[@]}" ; do
  if [ -d $nodenvdir/bin -a $FOUND_NODENV -eq 0 ] ; then
    FOUND_NODENV=1
    if [[ $NODENV_ROOT = '' ]]; then
      NODENV_ROOT=$nodenvdir
    fi
    export NODENV_ROOT
    export PATH=${nodenvdir}/bin:$PATH
    eval "$(nodenv init -)"

    function current_node() {
      echo "$(nodenv version)"
    }

    function nodenv_prompt_info() {
      echo "$(current_node)"
    }
  fi
done
unset nodenvdir

if [ $FOUND_NODENV -eq 0 ] ; then
  function nodenv_prompt_info() { echo "system: $(node --version)" }
fi
