#!/bin/bash
IFS=$'\n'
IP_COUNT=$(ip a | grep "inet " | grep -v 127.0.0.1 | egrep '((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])' | wc -l)
IP_MASTER=$(hostname -i | egrep '((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])')

if [ -z "$1" ]; then
    FILTER=127.0.0.1
else
    FILTER=$(echo "$1" | sed "s/:/\|/g")
fi

case $IP_COUNT in
1)
    LIST=$(ss -tnlp | tail -n +2 | awk -F \" '{print $1,$2}' | awk -F" " '{print $4,$7}' | egrep -v "$FILTER" | awk -F: '{print $NF}' | sort -n | uniq)
    ;;

*)
    LIST=$(ss -tnlp | tail -n +2 | awk -F \" '{print $1,$2}' | awk -F" " '{print $4,$7}' | egrep "^$IP_MASTER|^\*:[0-9]|^:::[0-9]" | egrep -v "$FILTER" | awk -F: '{print $NF}' | sort -n | uniq)
    ;;

esac

echo -e PORT_LIST=\'"$LIST"\' >/etc/zabbix/scripts/tcpmon/setenv.sh

echo -n '{"data":['
for s in $LIST; do
    PORT=$(echo $s | cut -d" " -f1)
    PROTO="tcp"
    SERVICE=$(echo $s | cut -d" " -f2)
    echo -n '{"{#PORT}":"'${PORT}'","{#PROTO}":"'${PROTO}'","{#SERVICE}":"'${SERVICE}'"},'
done | sed -e 's:\},$:\}:'
echo -n ']}'
unset IFS
