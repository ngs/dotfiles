if [ -f /usr/libexec/java_home ]; then
  export JAVA_HOME="$(/usr/libexec/java_home)"
  export PATH=${JAVA_HOME}/bin:${PATH}:
fi
export _JAVA_OPTIONS=-Duser.language=en
CLASSPATH=${CLASSPATH}
jars=( $(find "${HOME}/dotfiles/lib/java" -name "*.jar") )
for jar in ${jars}; do
    CLASSPATH=${CLASSPATH}:${jar}
done
export CLASSPATH
