#!/bin/bash - 
#===============================================================================
#
#          FILE:  revokeClient.sh
# 
#         USAGE:  ./revokeClient.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Nick Shevelev (Beggy), BeggyCode@gmail.com
#       COMPANY: BeggyCode
#       CREATED: 08/29/2014 10:06:04 AM UTC
#      REVISION:  ---
#===============================================================================

if [[ -z "$1" ]]; then 
    echo "Usage: $0 <client name>"
    exit 1
fi

declare -r CLIENT_NAME="$1"
source ./environment.sh

cd "${EASY_RSA_DIR}"
source ./vars;
./revoke-full "${CLIENT_NAME}" 
declare -r NEW_CLR_PEM="${OPEN_VPN_DIR}/$(basename "${CLR_PEM}")"
cp -v "${CLR_PEM}" "${NEW_CLR_PEM}"
chmod a=r "${NEW_CLR_PEM}"
if grep --quiet "^\s*#\s*crl-verify" "${SERVER_CONF}" ; then
    echo "don't forget uncoment crl-verify in ${SERVER_CONF}"
fi

