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

get_ipv6(){
        local ipv6=$(wget -qO- -t1 -T2 ipv6.icanhazip.com)
        if [ -z ${ipv6} ]; then
            return 1
        else
            return 0
        fi
}

pre_install()
{
    apt-get install update
    ipv6=get_ipv6
}

install_shadowsocks()
{
    apt-get install software-properties-common -y --force-yes
    add-apt-repository ppa:max-c-lv/shadowsocks-libev -y
    apt-get update
    apt install shadowsocks-libev
}

config_shadowsocks()
{
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

    chiper=${ciphers[$num-1]}

    
    cat > /etc/shadowsocks/config_ipv4.json<<-EOF
    {
        "server":${server},
        "server_port":${port},
        "local_address":"127.0.0.1",
        "local_port":1080,
        "password":"${password}",
        "timeout":600,
        "method":"${cipher}"
    }
    EOF
    
    if [ ipv6 -eq 1]; then
            read -p "enter your ipv6 server" ipv6_server
            cat > /etc/shadowsocks/config_ipv4.json<<-EOF
            {
                "server":${server},
                "server_port":${port},
                "local_address":"127.0.0.1",
                "local_port":1080,
                "password":"${password}",
                "timeout":600,
                "method":"${cipher}"
            }
            EOF
    fi    

}

firewall_set()
{
    apt-get install iptables-persistent
    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${port} -j ACCEPT
    iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${port} -j ACCEPT
    if [ ipv6 -eq 1 ]; then
        ip6tables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${port} -j ACCEPT
        ip6tables -I INPUT -m state --state NEW -m udp -p udp --dport ${port} -j ACCEPT
    fi

    service iptables-persistent save
    service iptables-persistent restart
}

add_service()
{
    #remove old
    update-rc.d -f shadowsocks-libev remove
    rm /etc/init.d/shadowsocks-libev
    rm -rf /var/run/shadowsocks-libev

    #build new
    chmod +x shadowsocks
    cp shadowsocks /etc/init.d/
    update-rc.d shadowsocks defaults
    service shadowsocks start
}

install()
{
    pre_install
    config_shadowsocks
    firewall_set
    install_shadowsocks
    add_serice
}

install
