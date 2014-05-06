# http://www.lejos.org
LEJOS_HOME=/opt/sdks/lejos_nxj
if [ -d $LEJOS_HOME ]; then
  export LEJOS_HOME
  export NXJ_HOME=${LEJOS_HOME}
  PATH=${LEJOS_HOME}/bin:$PATH
fi
