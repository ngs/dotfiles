SDKROOT=/opt/sdks

##
# Java
##
export JAVA_HOME=/Library/Java/Home
PATH=${PATH}:${JAVA_HOME}/bin

##
# Adobe Flex SDK
##
export FLEX_HOME=${SDKROOT}/flex_sdk_3
PATH=${PATH}:${FLEX_HOME}/bin

##
# LeJOS http://lejos.sourceforge.net/
##
export LEJOS_HOME=${SDKROOT}/lejos_nxj
export NXJ_HOME=${LEJOS_HOME}
PATH=${PATH}:${LEJOS_HOME}/bin

##
# Android SDK http://developer.android.com/sdk/
##
export ANDROID_HOME=${SDKROOT}/android-sdk-mac_x86
export ANDROID_SDK_ROOT=${ANDROID_HOME}
PATH=${PATH}:${ANDROID_HOME}/tools
PATH=${PATH}:${ANDROID_HOME}/platform-tools

##
# Amazon EC2 http://aws.amazon.com/developertools/351
##
export EC2_HOME=${SDKROOT}/ec2-api-tools
PATH=${PATH}:${EC2_HOME}/bin

##
# Google Storage http://code.google.com/apis/storage/docs/gsutil.html
##
export GSUTIL_HOME=${SDKROOT}/gsutil
export BOTO_HOME=${GSUTIL_HOME}/boto
PATH=${PATH}:${GSUTIL_HOME}:${BOTO_HOME}/bin
PYTHONPATH=${PYTHONPATH}:${HOME}/python/lib:${BOTO_HOME}

##
# Apple Developer Tools
##
PATH=${PATH}:/Developer/Tools

##
# Git http://code.google.com/p/git-osx-installer/
##
PATH=${PATH}:/usr/local/git/bin

##
# MySQL http://dev.mysql.com/downloads/mysql/
##
MYSQL_HOME=/usr/local/mysql
PATH=${PATH}:${MYSQL_HOME}/bin
LD_LIBRARY_PATH=${MYSQL_HOME}/lib:$LD_LIBRARY_PATH
LDFLAGS+=" -L${MYSQL_HOME}/lib "
CPPFLAGS+=" -I${MYSQL_HOME}/include "
DYLD_FALLBACK_LIBRARY_PATH=${MYSQL_HOME}/lib:$DYLD_FALLBACK_LIBRARY_PATH


##
# MeCab
##
PATH=${PATH}:/usr/local/mecab-0.98/bin

##
# Node
##
PATH=${PATH}:${HOME}/local/node/bin
export NODE_PATH=$HOME/local/node/lib/node_modules

##
# ClamXAV http://www.clamxav.com/
#
PATH=${PATH}:/usr/local/clamXav/bin

##
# Flash log
##
export FLASH_LOG="${HOME}/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt"

##
# JSDoc ToolKit
##
export JSDOCDIR="${SDKROOT}/jsdoc-toolkit"
export JSDOCTEMPLATEDIR="${JSDOCDIR}/templates/jsdoc"

##
# MacPorts
##
PATH=/opt/local/bin:${PATH}

##
# PEAR
##
PATH=${HOME}/pear/bin:${PATH}

##
# Postgres
##
export POSTGRES_HOME=/Library/PostgreSQL/Current
export PGDATA=${POSTGRES_HOME}/data
PATH=${POSTGRES_HOME}/bin:${PATH}

PATH=/Applications/Xcode.app/Contents/Developer/usr/bin:${PATH}

export PATH
export PYTHONPATH
source "${HOME}/dotfiles/bashrc"

alias ls='ls -G'
alias ll='ls -lsG'

export LD_LIBRARY_PATH
export LDFLAGS
export CPPFLAGS
export DYLD_FALLBACK_LIBRARY_PATH
export RAILS_ENV=localhost

export PATH=$PATH:/usr/local/CrossPack-AVR/bin
