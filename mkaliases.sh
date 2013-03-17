[ -e ".gitconfig"  ]        || ln -s dotfiles/gitconfig  .gitconfig
[ -e ".inputrc"    ]        || ln -s dotfiles/inputrc    .inputrc
[ -e ".proverc"    ]        || ln -s dotfiles/proverc    .proverc
[ -e ".screenrc"   ]        || ln -s dotfiles/screenrc   .screenrc
[ -e ".tmux.conf"  ]        || ln -s dotfiles/tmux.conf  .tmux.conf
[ -e ".vim"        ]        || ln -s dotfiles/vim        .vim
[ -e ".vim/vimrc"  ]        || ln -s dotfiles/vim/vimrc  .vimrc
[ -e ".vim/vimrc"  ]        || ln -s dotfiles/vim/vimrc  .vimrc
[ -e ".lynx.cfg"   ]        || ln -s dotfiles/lynx.cfg   .lynx.cfg
[ -e ".mm.cfg"     ]        || ln -s dotfiles/mm.cfg     .mm.cfg
[ -e ".jsdoc.conf" ]        || ln -s dotfiles/jsdoc.conf .jsdoc.conf
[ -e ".module-starter" ]    || ln -s dotfiles/module-starter .module-starter
[ -e ".subversion" ]        || mkdir .subversion
[ -e ".subversion/config" ] || ln -s dotfiles/subversion-config .subversion/config
[ -e ".tm_properties" ]     || ln -s dotfiles/tm_properties .tm_properties
[ -e ".ssh/config" ]        || ln -s dotfiles/ssh_config .ssh/config
[ -e ".rspec" ]             || ln -s dotfiles/rspec .ssh/rspec
[ -e ".gitignore" ]         || ln -s dotfiles/gitignore .ssh/gitignore
[ -e ".gemrc" ]             || ln -s dotfiles/gemrc .ssh/gemrc
