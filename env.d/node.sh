if command -v nodenv 1>/dev/null 2>&1; then
  eval "$(nodenv init -)"
fi

if command -v npm 1>/dev/null 2>&1; then
  NPM_ROOT=$(npm root -g)
  # tabtab source for serverless package
  # uninstall by removing these lines or running `tabtab uninstall serverless`
  [[ -f $NPM_ROOT/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && source $NPM_ROOT/serverless/node_modules/tabtab/.completions/serverless.zsh
  # tabtab source for sls package
  # uninstall by removing these lines or running `tabtab uninstall sls`
  [[ -f $NPM_ROOT/serverless/node_modules/tabtab/.completions/sls.zsh ]] && source $NPM_ROOT/serverless/node_modules/tabtab/.completions/sls.zsh
fi
