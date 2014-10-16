#!/bin/bash - 
#===============================================================================
#
#          FILE:  install.sh
# 
#         USAGE:  ./install.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Nick Shevelev (Beggy), BeggyCode@gmail.com
#       COMPANY: BeggyCode
#       CREATED: 08/28/2014 02:17:23 PM UTC
#      REVISION:  ---
#===============================================================================

source ./environment.sh

if [[ -d "${EASY_RSA_DIR}" ]]; then
    >&2 echo "${EASY_RSA_DIR} is already exist, please remove."
    exit 1
fi

apt-get update
apt-get -y install openvpn easy-rsa

mkdir -pv "${EASY_RSA_DIR}"
shopt -s extglob #to be sure we can use statement like !(vars)
cp -asv "${ORIGIN_EASY_RSA_DIR}"/!(vars) "${EASY_RSA_DIR}/" #create symbolic link for all except vars
cp -v "${ORIGIN_EASY_RSA_DIR}"/vars "${EASY_RSA_DIR}/"

cat - <<END_OF_TEXT

Install was completed. 
Edit ${EASY_RSA_DIR}/vars according to you preferences and run setupServer.sh or createClient.sh
END_OF_TEXT

