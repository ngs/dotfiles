if [ -f /usr/libexec/java_home ]; then
  export JAVA_HOME="$(/usr/libexec/java_home)"
  export PATH=${JAVA_HOME}/bin:${PATH}:
fi
CLASSPATH=${CLASSPATH}
jars=( $(find "${HOME}/dotfiles/lib/java" -name "*.jar") )
for jar in ${jars}; do
    CLASSPATH=${CLASSPATH}:${jar}
done
export CLASSPATH

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk"
