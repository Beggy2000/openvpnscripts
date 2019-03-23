#!/bin/bash -
#===============================================================================
#
#          FILE:  setupServer.sh
# 
#         USAGE:  ./setupServer.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Nick Shevelev (Beggy), BeggyCode@gmail.com
#       COMPANY: BeggyCode
#       CREATED: 08/25/2014 01:23:56 PM UTC
#      REVISION:  ---
#===============================================================================

#set -o nounset                              # Treat unset variables as an error

source ./environment.sh

cd "${EASY_RSA_DIR}"
source vars

if [[ ! -r "${KEY_CONFIG}" ]] ; then
    cat - <<END_OF_WRONG_KEY_CONFIG

The KEY_CONFIG variable point to not existing file. Please correct the vars file.
From https://linuxconfig.org/openvpn-setup-on-ubuntu-18-04-bionic-beaver-linux Step 2.1 - Variables setup: 
...
A very important variable is KEY_CONFIG, which, by default is set by calling a little wrapper script which should retrieve the right ssl configuration. However, if used this way it generates an error, because the script doesn't retrieve the configuration. To avoid this, we specify the configuration file directly:

export KEY_CONFIG="$EASY_RSA/openssl-1.0.0.cnf"
...
END_OF_WRONG_KEY_CONFIG
fi
./clean-all
./build-ca
./build-key-server "${SERVER_NAME}"
./build-dh
openvpn --genkey --secret "${TSL_SECRET}"
touch "${IFCONFIG_POOL}"
declare -r OPENVPN_NET_0="$(echo "${OPENVPN_NET}" | sed 's|/.*$||g')"

cat - > "${SERVER_CONF}" <<END_OF_SERVER_CONFIG
mode server

port 1194
# TCP or UDP server?
proto tcp

# "dev tun" will create a routed IP tunnel
dev tun 

# SSL/TLS root certificate (ca), certificate
# (cert), and private key (key).
ca ${CA_CRT}
cert ${SERVER_CRT}
key ${SERVER_KEY}

# Diffie hellman parameters.
dh ${DH_PEM}

#TSL
tls-server

# The server and each client must have
# a copy of this key.
tls-auth ${TSL_SECRET} 0
tls-timeout 120
auth SHA1
cipher BF-CBC

# Configure server mode and supply a VPN subnet
server ${OPENVPN_NET_0} 255.255.255.0

# Maintain a record of client <-> virtual IP address
# associations in this file. 
ifconfig-pool-persist ${IFCONFIG_POOL}

# Check peer certificate (uncomment after certificate revoke)
#crl-verify  $(basename "${CLR_PEM}")

# The keepalive directive causes ping-like
# messages to be sent back
keepalive 20 120 

# Enable compression on the VPN link.
comp-lzo yes

# The maximum number of concurrently connected
# clients we want to allow.
max-clients 10

# It's a good idea to reduce the OpenVPN
# daemon's privileges after initialization.
user nobody
group nogroup

# The persist options
persist-key
persist-tun
push "persist-key"
push "persist-tun"

# Log
# Output a short status
status ${STATUS_LOG}

# and log to 
log ${LOG}

# Set the appropriate level of log
verb 3

#Log at most n consecutive messages in the same category
mute 20

# to allow different clients 
# to be able to "see" each other.
client-to-client

# all IP network traffic originating 
# on client machines to pass through the OpenVPN server
push "redirect-gateway def1"

END_OF_SERVER_CONFIG
sed -n 's|^nameserver \(.*\)$|push "dhcp-option DNS \1"|gp' /etc/resolv.conf >> "${SERVER_CONF}"

sed -i "s|^[[:space:]]*#[[:space:]]*net\.ipv4\.ip_forward=1|net.ipv4.ip_forward=1|g" "/etc/sysctl.conf"
if ! grep --quiet "^net\.ipv4\.ip_forward=1" "/etc/sysctl.conf" ; then
    echo "net.ipv4.ip_forward=1" >> "/etc/sysctl.conf"
fi
sysctl -p

if [[ ! -e "${IPTABLE}" ]]; then

    cat - > "${IPTABLE}" <<END_OF_IPTABLE_CONF
#!/bin/bash

iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s ${OPENVPN_NET} -j ACCEPT
iptables -A FORWARD -j REJECT
iptables -t nat -A POSTROUTING -s ${OPENVPN_NET} -o eth0 -j MASQUERADE
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A INPUT -i tap+ -j ACCEPT
iptables -A FORWARD -i tap+ -j ACCEPT
END_OF_IPTABLE_CONF
    chmod a+rx "${IPTABLE}"
    source "${IPTABLE}"
fi
