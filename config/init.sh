#!/bin/sh

if [ -z $1 ]; then
	echo "0: no macvlan"
	echo "1: yes macvlan"
	exit 0
fi

if [ $1 -eq 1 ]; then
	tmp=hehe
	cat /etc/rc.local | while read line
	do
        	if [ "$line"x = "exit 0x" ]; then
                	break
        	fi
        	echo $line >> ${tmp}
	done

	echo "sleep 20" >> ${tmp}
	echo "ip link add link eth0.2 name veth1 type macvlan" >> ${tmp}
	echo "ifconfig veth1 up" >> ${tmp}
	echo "exit 0" >> ${tmp}

	cat ${tmp} > /etc/rc.local
	rm ${tmp}
fi

echo "net.ipv6.conf.default.accept_ra=2" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.accept_ra=2" >> /etc/sysctl.conf

uci set network.globals.ula_prefix="$(uci get network.globals.ula_prefix | sed 's/^./d/')"
uci commit network
uci set dhcp.lan.ra_default='1'
uci commit dhcp

file=/etc/init.d/nat6
touch ${file}
chmod +x ${file}

cat > ${file} <<-EOF
#!/bin/sh /etc/rc.common
START=75
ip6tables -t nat -I POSTROUTING -s \`uci get network.globals.ula_prefix\` -j MAS
route -A inet6 add 2000::/3 \`route -A inet6 | grep ::/0 | awk 'NR==1{print "gw "\$2" dev "\$7}'\`
EOF

${file} enable

opkg update
opkg install curl
reboot
