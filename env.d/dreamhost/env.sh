export MY_LOCAL=${HOME}/local

export JAVA_HOME=/usr/local/dh/java
export TZ=JST-9

##
# Google Storage http://code.google.com/apis/storage/docs/gsutil.html
##
export GSUTIL_HOME=${MY_LOCAL}/gsutil
export BOTO_HOME=${GSUTIL_HOME}/boto
PATH=${PATH}:${GSUTIL_HOME}:${BOTO_HOME}/bin
PYTHONPATH=${PYTHONPATH}:${BOTO_HOME}

export PYTHONPATH=${MY_LOCAL}/python/site-packages
export PKG_CONFIG_PATH=${MY_LOCAL}/lib/pkgconfig

export LD_LIBRARY_PATH=${MY_LOCAL}/lib
export LDFLAGS=-L${MY_LOCAL}/lib
export CPPFLAGS=-I${MY_LOCAL}/include
