ADOBE_AIR_HOME=/opt/sdks/AdobeAIRSDK
if [ -d $ADOBE_AIR_HOME ]; then
  export ADOBE_AIR_HOME
  export PATH=${ADOBE_AIR_HOME}/bin:${PATH}
fi


