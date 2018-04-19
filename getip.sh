#!/bin/bash


init()
{
	file=/home/lucky/ip

	ipv6=$(ifconfig eth0 | grep Global | awk '{print $3}')
	ipv6=${ipv6%%/*}

	ipv4=$(ifconfig eth0 | awk '{if (NR==2) print $2}')
	ipv4=${ipv4:5}
		
	server=$(cat /etc/shadowsocks/config_ipv6.json | awk '{if (NR==2) print $2}')
	server=${server:1}
	server=${server%\"*}
}

send()
{
		echo "ipv4: ${ipv4}" > $file
		echo "<br>" >> $file
		echo "ipv6: ${ipv6}" >> $file
		scp $file root@[${server}]:/usr/share/nginx/html/V$1.html
}

init
if [ -f $file ]; then
	ip=$(cat $file | awk '{if (NR==1) print $2}')
	if [ "$ip" == "$ipv4" ]; then
		send $1
	fi
else
	send $1	
fi



