LD_LIBRARY_PATH=/usr/lib
if [ -d /usr/lib64 ]; then
  LD_LIBRARY_PATH="/usr/lib64:${LD_LIBRARY_PATH}"
  LDFLAGS="-L/usr/lib64 ${LDFLAGS}"
fi
if [ -d /usr/local/lib ]; then
  LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
  LDFLAGS="-L/usr/local/lib ${LDFLAGS}"
fi
if [ -d /usr/local/lib64 ]; then
  LD_LIBRARY_PATH="/usr/local/lib64:${LD_LIBRARY_PATH}"
  LDFLAGS="-L/usr/local/lib64 ${LDFLAGS}"
fi
if [ -d $HOME/local/lib ]; then
  LD_LIBRARY_PATH="${HOME}/local/lib:${LD_LIBRARY_PATH}"
fi
CPPFLAGS="-fPIC "
if [ -d /usr/local/include ]; then
  CPPFLAGS+="-I/usr/local/include ${CPPFLAGS}"
fi
if [ -d "${HOME}/local/include" ]; then
  CPPFLAGS+="-I${HOME}/local/include ${CPPFLAGS}"
fi
CFLAGS+=$CPPFLAGS
#export DYLD_FALLBACK_LIBRARY_PATH=$DYLD_FALLBACK_LIBRARY_PATH:/usr/local/lib:$HOME/local/lib
#export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/lib:$HOME/local/lib

export LD_LIBRARY_PATH
export ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future
export CFLAGS
export CPPFLAGS
export LDFLAGS
