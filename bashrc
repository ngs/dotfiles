##
# Env.
##
export LANG=en_US.UTF-8
export EDITOR=vim
export LC_ALL=en_US.UTF-8
export CLICOLOR=1
export LSCOLORS=dxgxcxdxcxegedabagacad
export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib
export LDFLAGS+=-L/usr/local/lib
export CPPFLAGS+=-I/usr/local/include
export DYLD_FALLBACK_LIBRARY_PATH=/usr/local/lib:$DYLD_FALLBACK_LIBRARY_PATH

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
# Java CLASSPATH
##
CLASSPATH=${CLASSPATH}
jars=( $(find "${HOME}/dotfiles/java/lib" -name "*.jar") )
for jar in ${jars}; do
    CLASSPATH=${CLASSPATH}:${jar}
done
export CLASSPATH

##
# Refercences
##
source "${HOME}/dotfiles/bashfunctions"
source "${HOME}/dotfiles/aliases"

if [ -d "${HOME}/perl5" ]; then
    source "${HOME}/perl5/perlbrew/etc/bashrc"
fi

if [ -d "${HOME}/.pythonbrew" ]; then
    source "${HOME}/.pythonbrew/etc/bashrc"
fi
