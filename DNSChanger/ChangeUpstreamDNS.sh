#!/bin/ash

# set parameters
PATH_BACKUP_RESOLV_CONF="/etc/resolvbackup.conf"
PATH_DEFAULT_RESOLV_CONF="/etc/resolvdefault.conf"
MAIL="user@example.com"

# init DNS config to be set to default DNS config
dns_config_to_set=$PATH_DEFAULT_RESOLV_CONF
# get default DNS IP from config
IP_DEFAULT_DNS=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' $PATH_DEFAULT_RESOLV_CONF | head -1)

# get test result of default DNS
result=$(dig +short @$IP_DEFAULT_DNS example.com)

# if default DNS is not availble, mark backup DNS as to be enabled
if echo $result|grep "connection timed out" - > /dev/null; then
  dns_config_to_set=$PATH_BACKUP_RESOLV_CONF
fi

# test if DNS config needs to be updated
# 1) if default DNS is available but backup DNS config is enabled
# 2) if default DNS is not available and backup DNS config is not enabled
if [ `uci get dhcp.@dnsmasq[0].resolvfile` != $dns_config_to_set ]; then
  uci set dhcp.@dnsmasq[0].resolvfile=$dns_config_to_set
  uci commit dhcp
  /etc/init.d/dnsmasq restart > /dev/null 2>&1
  echo "Subject:$HOSTNAME DNS config '$dns_config_to_set' enabled" | /usr/bin/msmtp $MAIL
fi
