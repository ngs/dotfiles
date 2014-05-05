export LD_LIBRARY_PATH=/usr/lib:$HOME/local/lib:/usr/local/lib:/usr/lib64:/usr/local/lib64
LDFLAGS+=" -L/usr/local/lib64 -L/usr/lib -L/usr/lib64 -L/usr/local/lib -L$HOME/local/lib "
CPPFLAGS+=" -I/usr/local/include -I$HOME/local/include -fPIC "
CFLAGS+=" -I/usr/local/include -I$HOME/local/include -fPIC "
#export DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH:/usr/local/lib:$HOME/local/lib
#export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/lib:$HOME/local/lib

export ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future
export CFLAGS
export CPPFLAGS
export LDFLAGS
