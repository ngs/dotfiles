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

propen() {
  local current_branch_name=$(git symbolic-ref --short HEAD | ruby -ruri -e 'print URI.escape STDIN.read.strip')
  git config --get remote.origin.url | sed -e "s/^.*[:\/]\(.*\/.*\).git$/https:\/\/github.com\/\1\//" | sed -e "s/$/pull\/${current_branch_name}/" | xargs open
}

cfls() {
  aws cloudfront list-distributions --output table --query 'DistributionList.Items[*].[DomainName,Id,Origins.Items[0].DomainName]'
}
