#!/bin/bash

ipv6=0

ciphers=(
aes-256-gcm
aes-192-gcm
aes-128-gcm
aes-256-ctr
aes-192-ctr
aes-128-ctr
aes-256-cfb
aes-192-cfb
aes-128-cfb
camellia-128-cfb
camellia-192-cfb
camellia-256-cfb
xchacha20-ietf-poly1305
chacha20-ietf-poly1305
chacha20-ietf
chacha20
salsa20
rc4-md5
)

get_ipv6()
{
        local ipv6=$(wget -qO- -t1 -T2 ipv6.icanhazip.com)
        if [ -z ${ipv6} ]; then
            return 1
        else
            return 0
        fi
}

add_rclocal()
{
	cat /etc/rc.local | while read line
	do
		if [ "x$line" != "xexit 0" ] ; then
			echo $line >> tmp
		else
			echo "hev-dns-forwarder" >> tmp
			echo "exit 0" >> tmp
		fi
	done
	cp tmp /etc/rc.local
}

pre_install()
{
    apt-get update
    apt-get install iptables-persistent
    wget https://raw.githubusercontent.com/luckywei88/shadowsocks/master/shadowsocks

    git clone git://github.com/heiher/hev-dns-forwarder
    pushd hev-dns-forwarder
    make
    pushd src
    cp hev-dns-forwarder /usr/sbin
    popd
    popd
}

install_shadowsocks()
{
    apt-get install software-properties-common -y --force-yes
    add-apt-repository ppa:max-c-lv/shadowsocks-libev -y
    apt-get update
    apt install shadowsocks-libev
    
    apt-get install dnsmasq
}

config_shadowsocks()
{
    if get_ipv6; then
	ipv6=1
    fi
    if [ ! -d /etc/shadowsocks ]; then
        mkdir -p /etc/shadowsocks
    fi
    
    read -p "enter your ipv4 server" server
    read -p "enter your port" port
    read -p "enter your passwd" password

    echo -e "Please select stream cipher for shadowsocks-libev:"
    for ((i=1;i<=${#ciphers[@]};i++ )); do
        hint="${ciphers[$i-1]}"
        echo -e "${i} ${hint}"
    done

    read -p "enter your ciphers" num

    cipher=${ciphers[$num-1]}

    
    cat > /etc/shadowsocks/config_ipv4.json<<-EOF
{
	"server":${server},
        "server_port":${port},
        "local_address":"127.0.0.1",
        "local_port":1080,
        "password":"${password}",
        "timeout":600,
	"fast_open": false,
	"use_syslog": false,
	"ipv6_first": false,
	"reuse_port": false,
	"disable_sni": false,
        "method":"${cipher}"
}
EOF
    
    if [ $ipv6 -eq 1 ]; then
            read -p "enter your ipv6 server" ipv6_server
            cat > /etc/shadowsocks/config_ipv6.json<<-EOF
{
	"server":${ipv6_server},
        "server_port":${port},
        "local_address":"127.0.0.1",
        "local_port":1080,
        "password":"${password}",
        "timeout":600,
	"fast_open": false,
	"use_syslog": false,
	"ipv6_first": false,
	"reuse_port": false,
	"disable_sni": false,
        "method":"${cipher}"
}
EOF
    fi    

}

firewall_set()
{
    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${port} -j ACCEPT
    iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${port} -j ACCEPT
    if [ $ipv6 -eq 1 ]; then
        ip6tables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${port} -j ACCEPT
        ip6tables -I INPUT -m state --state NEW -m udp -p udp --dport ${port} -j ACCEPT
    fi

    iptables -t nat -A OUTPUT -p tcp -j REDIRECT --to-ports 1080
    service iptables-persistent save
    service iptables-persistent restart
}

add_service()
{
    #remove old
    service shadowsocks-libev stop
    update-rc.d -f shadowsocks-libev remove
    rm /etc/init.d/shadowsocks-libev
    rm -rf /var/run/shadowsocks-libev

    #build new
    chmod +x shadowsocks
    mv shadowsocks /etc/init.d/
    update-rc.d shadowsocks defaults
    service shadowsocks start

    #set dns ipv4 first
    echo "precedence ::ffff:0:0/96 100" >> /etc/gai.conf

    #modify dns server
    echo "server=127.0.0.1#5300" >> /etc/dnsmasq.conf  
}

install()
{
    pre_install
    config_shadowsocks
    firewall_set
    install_shadowsocks
    add_service
    add_rclocal
}

install 2>&1 | tee $0.log
