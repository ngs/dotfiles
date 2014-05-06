# $Id$

calc(){
    awk "BEGIN{ print $* }" ;
}

gs() {
    open -a Safari "http://www.google.com/search?q=$1";
}

line() {
    echo '-----------------------------------------------------------------------------------'
}

gitinit() {
    remote=$1
    git init .
    echo '* filter=ident' > .gitattributes
    touch README
    echo ".DS_Store
.prove
.*.swp
*.mode1v3
*.pbxuser
build
Build
_build
MYMETA.yml
" > .gitignore
    git add .gitignore README .gitattributes
    git commit -a -m "Initial"
    git remote add origin $remote
    git push origin master
}

closure() {
    ARG=$*
    if [ "$ARG" = '' ]; then
        ARG='--help'
    fi;
    java com.google.javascript.jscomp.CommandLineRunner $ARG 2>&1;
}

jslint() {
  ARG=$1
  JSLINT="${HOME}/dotfiles/tools/jslint.js"
  if [ -f "$ARG" ]; then
    java org.mozilla.javascript.tools.shell.Main "$JSLINT" "$ARG" 2>&1
  else
    echo "File not found: $ARG"
  fi
}

js() {
    java org.mozilla.javascript.tools.shell.Main $* 2>&1
}

jpegtopng() {
    if [ ! -z "$1" ]; then
        if [ -z "$2" ]; then
            jpegtopnm $1 | pnmtopng > ${1%.*}.png
        else
            jpegtopnm $1 | pnmtopng > $2
        fi
    fi
}

svn-mime() {
    find . -name "*.html" | xargs svn ps svn:mime-type text/html
    find . -name "*.xml" | xargs svn ps svn:mime-type text/xml
    find . -name "*.css" | xargs svn ps svn:mime-type text/css
    find . -name "*.js" | xargs svn ps svn:mime-type text/javascript
    find . -name "*.png" | xargs svn ps svn:mime-type image/png
    find . -name "*.gif" | xargs svn ps svn:mime-type image/gif
    find . -name "*.jpg" | xargs svn ps svn:mime-type image/jpeg
    find . -name "*.swf" | xargs svn ps svn:mime-type application/x-shockwave-flash
}

jsdoc() {
    ARG=$*
    ARGCONF=''
    if [ "$1" != '--conf' ]; then
        ARGCONF="--conf=${HOME}/.jsdoc.conf"
    fi
    ${JSDOCDIR}/jsrun.sh $ARGCONF $ARG
}

standby() {
osascript << EOT
tell application "System Events"
    sleep
end
EOT
}

function pg_terminate_backend() {
  psql -Upostgres -c "SELECT pg_terminate_backend(procpid) FROM pg_stat_activity WHERE procpid <> pg_backend_pid() AND datname = '$1';"
}
