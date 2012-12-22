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
# Adobe Font Development Kit for OpenType
##
export FDK_HOME=${SDKROOT}/FDK
PATH=${PATH}:${FDK_HOME}/Tools/osx


##
# Adobe AIR SDK
##
export ADOBE_AIR_HOME=${SDKROOT}/AdobeAIRSDK
PATH=${PATH}:${ADOBE_AIR_HOME}/bin

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
# AWS Elastic Beanstalk http://aws.amazon.com/code/6752709412171743
##
export EB_HOME=${SDKROOT}/awseb
PATH=${PATH}:${EB_HOME}/eb/macosx/python2.7

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
# php-version
##
export PHP_VERSIONS=$HOME/php/versions
PHP_VERSION=$(/usr/local/bin/brew --prefix php-version)/php-version.sh
if [ -f "$PHP_VERSION" ]; then
  source $PHP_VERSION  && php-version 5.4.4 >/dev/null
fi

##
# Postgres
##
PATH="/Applications/Postgres.app/Contents/MacOS/bin:$PATH"
export PGDATA="${HOME}/Application Support/Postgres/var"

PATH=/Applications/Xcode.app/Contents/Developer/usr/bin:${PATH}

export PATH
export PYTHONPATH
source "${HOME}/dotfiles/bashrc"

alias ls='ls -G'
alias ll='ls -lsG'

export LD_LIBRARY_PATH
export LDFLAGS
export CPPFLAGS
export RAILS_ENV=localhost

export PATH=$PATH:/usr/local/CrossPack-AVR/bin
