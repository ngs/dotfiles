ANDROID_HOME=$HOME/Library/Android/sdk

if [ -d $ANDROID_HOME ]; then
  export PATH="${ANDROID_HOME}/platform-tools:${PATH}"
fi


