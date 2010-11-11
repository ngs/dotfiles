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
PYTHONPATH=${PYTHONPATH}:${BOTO_HOME}

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
PATH=${PATH}:/usr/local/mysql/bin
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

export PATH
export PYTHONPATH
source "${HOME}/dotfiles/bashrc"