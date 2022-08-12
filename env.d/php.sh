PHPENV_ROOT="$HOME/.phpenv"

if [ -d $PHPENV_ROOT ]; then
  export PHP_BUILD_CONFIGURE_OPTS="--with-zlib-dir=$(brew --prefix zlib) --with-bz2=$(brew --prefix bzip2) --with-curl=$(brew --prefix curl) --with-iconv=$(brew --prefix libiconv) --with-libedit=$(brew --prefix libedit) --with-ssl=$(brew --prefix openssl@1.1)"
  export PATH="$PHPENV_ROOT/bin:$PATH"
	eval "$(phpenv init -)"
fi
