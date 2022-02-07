# OpenWRTDNSUpstreamChanger
This script changes the upstream DNS resolver of OpenWRT dnsmasq in case e.g. a local default DNS resolver (e.g. pi-hole) used as upstream resolver is unavailable or switching back to the default DNS upstream resolver in case it becomes available again. The scripts sends a mail if the DNS config is switched.

The script might be helpful if you deployed a local DNS resolver such as pi-hole. In this case, you will probably enable dnsmasq's option 'strict order' to have all your DNS request be processed by pi-hole. However, by enabling the strict order setting, the availability of your local pi-hole DNS resolver becomes crucial. In case the local pi-hole service is unavailable, DNS queries will time out before being send by OpenWRT to a secondary DNS defined in the config. Thus, your clients will experience DNS queries to be long running. In this scenario the provided script will regularly check if the local pi-hole service is available. If it is not, the script changes OpenWRT's upstream DNS resolver to a defined backup. The script also reverts OpenWRT upstream DNS resolver setting back to your local pi-hole DNS resolver once it becomes available again.

## Dependencies
Install 'bind-dig' and 'msmtp' package.
```
opkg update
opkg install bind-dig msmtp
```
## Copy files
Move DNS change script to /root and resolv configurations to /etc.

```
mv -r DNSChanger /root
mv resolvbackup.conf resolvdefault.conf /etc
```

## Enable dnsmasq 'strict order'
Enable dnsmasq's option 'strict order' to ensure that always the defined primary upstream DNS resolver is used. This is a reasonable setting in case you want all DNS queries to be processed by your primary DNS i.e. if you deployed a pi-hole service which shall process all DNS queries.
```
uci set dhcp.@dnsmasq[0].strictorder=1
uci commit dhcp
/etc/init.d/dnsmasq restart
```

## Change settings
Change the resolv configurations to your setting.
```
nano /etc/resolvbackup.conf
nano /etc/resolvdefault.conf
```
Add your mail credentials to msmtprc configuration.
```
nano /etc/msmtprc
```
Change email recipient and sender in script.
```
nano /root/DNSChanger/ChangeUpstreamDNS.sh
```

## Make DNS change script executable for cron
```
sudo chmod +x /root/DNSChanger/ChangeUpstreamDNS.sh
```

## Add cronjob
For example, add a cronjob checking the default DNS every 5 minutes..
```
crontab -e
```
Add the follwing line.
```
*/5 * * * * sh /root/DNSChanger/ChangeUpstreamDNS.sh
```

## Start and enable cron
```
/etc/init.d/cron start
/etc/init.d/cron enable
```
