# Detect architecture and set appropriate Homebrew prefix
if [ "$(uname -m)" = "arm64" ]; then
  # Apple Silicon
  HOMEBREW_PREFIX="/opt/homebrew"
else
  # Intel
  HOMEBREW_PREFIX="/usr/local"
fi

# Try openssl@3 first, then fall back to openssl
if [ -d "${HOMEBREW_PREFIX}/opt/openssl@3" ]; then
  OPENSSL_PATH="${HOMEBREW_PREFIX}/opt/openssl@3"
elif [ -d "${HOMEBREW_PREFIX}/opt/openssl" ]; then
  OPENSSL_PATH="${HOMEBREW_PREFIX}/opt/openssl"
fi

if [ -n "${OPENSSL_PATH}" ]; then
  LDFLAGS+=" -L${OPENSSL_PATH}/lib "
  CPPFLAGS+=" -I${OPENSSL_PATH}/include "
  LD_LIBRARY_PATH="${OPENSSL_PATH}/lib:${LD_LIBRARY_PATH}"
  export LD_LIBRARY_PATH
  export LDFLAGS
  export CPPFLAGS
fi
