#!/bin/bash

workdir=/home/lucky/openwrt_all/
out_luci=luci/
out_net=packages/net/
out_lib=packagse/libs/
in_luci=openwrt/package/luci
in_net=openwrt/package/network
in_lib=openwrt/package/libs

required_net=
(
	openwrt-chinadns
	openwrt-dns-forwarder
	shadowsocks-libev
)

required_libs=
(
	c-ares
	libsodium
	libev
	libpcre	
)

required_luci=
(
	openwrt-dist-luci
	luci-app-shadowsocks-libev
)


download()
{
	git clone https://github.com/openwrt/openwrt.git
	pushd openwrt
	tsocks ./scripts/feeds update -a
	tsocks ./scripts/feeds install -a
	tsocks ./scripts/update luci
	tsocks ./scripts/install luci
	popd
	pushd $out_net
	git clone https://github.com/aa65535/openwrt-chinadns.git
	git clone https://github.com/aa65535/openwrt-dns-forwarder.git
	popd
	pushd $out_luci
	git clone https://github.com/aa65535/openwrt-dist-luci.git
	popd
}
