##
# Env.
##
export LANG=en_US.UTF-8
export EDITOR=vim
export LC_ALL=en_US.UTF-8
export CLICOLOR=1
export LSCOLORS=dxgxcxdxcxegedabagacad

##
# Perl
##
export PERL_AUTOINSTALL="--alldeps"
export COPY_EXTENDED_ATTRIBUTES_DISABLE=1

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
export PATH=${PATH}:"${HOME}/bin":"${HOME}/dotfiles/bin"

##
# Refercences
##
source "${HOME}/dotfiles/bashfunctions"
source "${HOME}/dotfiles/aliases"
source "${HOME}/perl5/perlbrew/etc/bashrc"
source "${HOME}/.pythonbrew/etc/bashrc"
