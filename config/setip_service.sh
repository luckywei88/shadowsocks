#!/bin/sh

ss=SHADOWSOCKS
out=OUTPUT
ip_pass=ip_pass
file=/etc/chinadns_chnroute.txt

iptables -t nat -A ${out} -p tcp -d 8.8.4.4 -j REDIRECT --to-ports 1080

iptables -t nat -N ${ss}
iptables -t nat -F ${ss}

while read address
do
	iptables -t nat -A ${ss} -d ${address} -j RETURN
done < ${ip_pass}

#curl -sL http://f.ip.cn/rt/chnroutes.txt | egrep -v '^\s*$|^\s*#' > ${file}

while read line
do  
    iptables -t nat -A ${ss} -d ${line} -j RETURN
done < ${file}

iptables -t nat -A ${ss} -p tcp -j REDIRECT --to-ports 1080
iptables -t nat -A PREROUTING -p tcp -j ${ss}

#/usr/bin/ss-server -u -c /root/ss_server.json
