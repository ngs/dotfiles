##
# Env.
##
export LANG=en_US.UTF-8
export EDITOR=vim
export LC_ALL=en_US.UTF-8
export CLICOLOR=1
export LSCOLORS=dxgxcxdxcxegedabagacad
export LD_LIBRARY_PATH=/usr/lib:$HOME/local/lib:/usr/local/lib:/usr/lib64:/usr/local/lib64
export LDFLAGS+=" -L/usr/local/lib64 -L/usr/lib -L/usr/lib64 -L/usr/local/lib -L$HOME/local/lib "
export CPPFLAGS+=" -I/usr/local/include -I$HOME/local/include -fPIC "
export CFLAGS+=" -I/usr/local/include -I$HOME/local/include -fPIC "
#export DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH:/usr/local/lib:$HOME/local/lib
#export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/lib:$HOME/local/lib

##
# Perl
##
export PERL_AUTOINSTALL="--alldeps"
export COPY_EXTENDED_ATTRIBUTES_DISABLE=1

##
# rvm
##
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm" 

##
# pythonbrew
##
[[ -s $HOME/.pythonbrew/etc/bashrc ]] && source $HOME/.pythonbrew/etc/bashrc

##
# Java
##
export _JAVA_OPTIONS=-Duser.language=en

##
# Amazon EC2
##
export EC2_PRIVATE_KEY=~/.ec2/pk.pem
export EC2_CERT=~/.ec2/cert.pem

##
# Pathes
##
export PATH="${HOME}/bin":"${HOME}/local/bin":"${HOME}/dotfiles/bin":/usr/local/bin:/usr/local/sbin:${PATH}

##
# Java CLASSPATH
##
CLASSPATH=${CLASSPATH}
jars=( $(find "${HOME}/dotfiles/java/lib" -name "*.jar") )
for jar in ${jars}; do
    CLASSPATH=${CLASSPATH}:${jar}
done
export CLASSPATH

##
# rvm
##
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function

##
# Refercences
##
source "${HOME}/dotfiles/bashfunctions"
source "${HOME}/dotfiles/aliases"

##
# node
##
if [ -d ${HOME}/local/node/lib/node_modules/less/bin ]; then
  export PATH=${HOME}/local/node/lib/node_modules/less/bin:$PATH
fi

if [ -d "${HOME}/perl5" ]; then
    source "${HOME}/perl5/perlbrew/etc/bashrc"
fi

if [ -d "${HOME}/.pythonbrew" ]; then
    source "${HOME}/.pythonbrew/etc/bashrc"
fi

# http://www.commandlinefu.com/commands/view/10046/automatically-rename-tmux-window-using-the-current-working-directory
f(){ if [ "$PWD" != "$LPWD" ];then LPWD="$PWD"; [ $TMUX ] && tmux rename-window ${PWD//*\//}; fi }; export PROMPT_COMMAND=f;
