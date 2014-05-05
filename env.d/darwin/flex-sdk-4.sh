FLEX_HOME=/opt/sdks/flex_sdk_3
if [ -d $FLEX_HOME ]; then
  export FLEX_HOME
  export PATH=${FLEX_HOME}/bin:${PATH}
fi
