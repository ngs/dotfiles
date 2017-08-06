export PERL_AUTOINSTALL="--alldeps"
export COPY_EXTENDED_ATTRIBUTES_DISABLE=1

if [ -d $HOME/.plenv ]; then
  export PATH=$HOME/.plenv/shims:$PATH
  eval "$(plenv init -)"
fi

if [ -d $HOME/perl5/bin ]; then
  export PATH=$HOME/perl5/bin:$PATH
fi

PATH="$HOME/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="$HOME/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="$HOME/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;
