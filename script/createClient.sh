#!/bin/bash - 
#===============================================================================
#
#          FILE:  createClient.sh
# 
#         USAGE:  ./createClient.sh 
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

if [[ -z "${SERVER_IP}" ]]; then
    echo "Please define SERVER_IP in ./environment.sh"
    exit 1
fi

cd "${EASY_RSA_DIR}"
source ./vars;
./build-key "${CLIENT_NAME}"

declare -r RELATIVE_CLIENT_CONF="${CLIENT_CONF#${OPEN_VPN_DIR}/}"
declare -r RELATIVE_CLIENT_CRT="${CLIENT_CRT#${OPEN_VPN_DIR}/}"
declare -r RELATIVE_CLIENT_KEY="${CLIENT_KEY#${OPEN_VPN_DIR}/}"
declare -r RELATIVE_CA_CRT="${CA_CRT#${OPEN_VPN_DIR}/}"
declare -r RELATIVE_TSL_SECRET="${TSL_SECRET#${OPEN_VPN_DIR}/}"

cat - > "${CLIENT_CONF}" <<END_OF_CLIENT_CONF
#client option implies pull as well
client

#connect to VPN server
remote ${SERVER_IP} 1194

dev tun
proto tcp

#remove to use your ISP's gateway
redirect-gateway def1

#your access keys
ca ${RELATIVE_CA_CRT}
cert ${RELATIVE_CLIENT_CRT}
key ${RELATIVE_CLIENT_KEY}
tls-auth ${RELATIVE_TSL_SECRET} 1

#keep trying indefinitely to resolve the host name of the OpenVPN server.
resolv-retry infinite

#most clients don't need to bind to a specific local port number.
nobind

#set log file verbosity.
verb 4

#silence repeating messages
mute 20

# Enable compression on the VPN link.
compress lz4-v2

#Encrypt data channel packets with cipher algorithm
cipher AES-256-CBC

#Authenticate data channel packets and (if enabled) tls-auth control channel packets
auth SHA256

#Allow calling of built-in executables and user-defined scripts.
script-security 2

#script update DNS(/etc/resolv.conf)
up /etc/openvpn/update-systemd-resolved
down /etc/openvpn/update-systemd-resolved
down-pre

# prevent DNS leakage (see: https://github.com/systemd/systemd/issues/6076#issuecomment-387332572)
dhcp-option DOMAIN-ROUTE .
END_OF_CLIENT_CONF

tar --auto-compress --create --directory "${OPEN_VPN_DIR}" --file "${CURRENT_DIR}/${CLIENT_NAME}.tar.gz" "${RELATIVE_CLIENT_CONF}" "${RELATIVE_CLIENT_CRT}" "${RELATIVE_CLIENT_KEY}" "${RELATIVE_CA_CRT}" "${RELATIVE_TSL_SECRET}" 
rm "${CLIENT_CONF}" 
