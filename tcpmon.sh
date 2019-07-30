#!/bin/bash

domain_name="$(hostname -d)"
case $domain_name in
sumpay.local)
    proxy_ip=192.168.61.238
    zabbix_ip=192.168.61.239
    ;;

sumpay.xs)
    proxy_ip=172.16.130.238
    zabbix_ip=172.16.130.239
    ;;

sumpay.sd)
    proxy_ip=172.16.131.238
    zabbix_ip=172.16.131.239
    ;;

*)
    echo Cannot accquire DNS domain name.
    exit 123
    ;;

esac

if [ -e /etc/zabbix/zabbix_agentd.d/userparameter_tcpsrv.conf ]; then
    rm -f /etc/zabbix/zabbix_agentd.d/userparameter_tcpsrv.conf /etc/zabbix/scripts/tcpsrv_discovery.sh
fi

sed -i "/tcpsrv_discovery.sh/d" /etc/sudoers.d/zabbix

if [ ! -s /etc/sudoers.d/zabbix ]; then
    rm -f /etc/sudoers.d/zabbix
fi

mkdir -p /etc/zabbix/scripts/tcpmon
curl http://$proxy_ip/software/zabbix/tcpmon/tcp_port_discovery.sh -o /etc/zabbix/scripts/tcpmon/tcp_port_discovery.sh
curl http://$proxy_ip/software/zabbix/tcpmon/tcp_status_master.sh -o /etc/zabbix/scripts/tcpmon/tcp_status_master.sh
curl http://$proxy_ip/software/zabbix/tcpmon/userparameter_tcpstatus.conf -o /etc/zabbix/zabbix_agentd.d/userparameter_tcpstatus.conf
curl http://$proxy_ip/software/zabbix/tcpmon/zabbix-tcpmon -o /etc/sudoers.d/zabbix-tcpmon
chmod +x /etc/zabbix/scripts/tcpmon/tcp_port_discovery.sh /etc/zabbix/scripts/tcpmon/tcp_status_master.sh
chmod 440 /etc/sudoers.d/zabbix-tcpmon

service zabbix-agent restart
