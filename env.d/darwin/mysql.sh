##
# MySQL http://dev.mysql.com/downloads/mysql/
##
export MYSQL_HOME=/usr/local/opt/mysql
LD_LIBRARY_PATH=${MYSQL_HOME}/lib:$LD_LIBRARY_PATH
LDFLAGS+=" -L${MYSQL_HOME}/lib "
CPPFLAGS+=" -I${MYSQL_HOME}/include "
export LD_LIBRARY_PATH
export LDFLAGS
export CPPFLAGS
