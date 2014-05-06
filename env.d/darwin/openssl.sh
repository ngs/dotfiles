LDFLAGS+=' -L/usr/local/opt/openssl/lib '
CPPFLAGS+=' -I/usr/local/opt/openssl/include '
LD_LIBRARY_PATH=/usr/local/opt/openssl/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH
export LDFLAGS
export CPPFLAGS
