#configuration file

declare -r CURRENT_DIR="$(pwd)"
declare -r OPEN_VPN_DIR="/etc/openvpn"
declare -r EASY_RSA_DIR="${OPEN_VPN_DIR}/easy-rsa"
declare -r KEYS_DIR="${OPEN_VPN_DIR}/easy-rsa/keys"
declare -r ORIGIN_EASY_RSA_DIR="/usr/share/easy-rsa"

declare -r SERVER_NAME="server"
declare -r SERVER_IP=""
declare -r TSL_SECRET="${KEYS_DIR}/ta.key"
declare -r CLR_PEM="${KEYS_DIR}/crl.pem"
declare -r SERVER_CONF="${OPEN_VPN_DIR}/${SERVER_NAME}.conf"
declare -r CA_CRT="${KEYS_DIR}/ca.crt"
declare -r SERVER_CRT="${KEYS_DIR}/server.crt"
declare -r SERVER_KEY="${KEYS_DIR}/server.key"
declare -r DH_PEM="${KEYS_DIR}/dh2048.pem"
declare -r IFCONFIG_POOL="${OPEN_VPN_DIR}/ipp.txt"
declare -r STATUS_LOG="${OPEN_VPN_DIR}/openvpn-status.log"
declare -r LOG="/var/log/openvpn.log"

declare -r CLIENT_CONF="${OPEN_VPN_DIR}/${CLIENT_NAME}.conf"
#declare -r CLIENT_OVPN="${OPEN_VPN_DIR}/${CLIENT_NAME}.ovpn"
declare -r CLIENT_OVPN="${CLIENT_CONF}"
declare -r CLIENT_CRT="${KEYS_DIR}/${CLIENT_NAME}.crt"
declare -r CLIENT_KEY="${KEYS_DIR}/${CLIENT_NAME}.key"

declare -r IPTABLE="/etc/network/if-up.d/iptable_openvpn"
declare -r OPENVPN_NET="" #Eg. 178.98.0.0/24
