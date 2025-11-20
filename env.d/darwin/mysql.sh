##
# MySQL http://dev.mysql.com/downloads/mysql/
##
# Detect architecture and set appropriate Homebrew prefix
if [ "$(uname -m)" = "arm64" ]; then
  # Apple Silicon
  HOMEBREW_PREFIX="/opt/homebrew"
else
  # Intel
  HOMEBREW_PREFIX="/usr/local"
fi

if [ -d "${HOMEBREW_PREFIX}/opt/mysql" ]; then
  export MYSQL_HOME="${HOMEBREW_PREFIX}/opt/mysql"
  LD_LIBRARY_PATH="${MYSQL_HOME}/lib:${LD_LIBRARY_PATH}"
  LDFLAGS+=" -L${MYSQL_HOME}/lib "
  CPPFLAGS+=" -I${MYSQL_HOME}/include "
  export LD_LIBRARY_PATH
  export LDFLAGS
  export CPPFLAGS
fi
