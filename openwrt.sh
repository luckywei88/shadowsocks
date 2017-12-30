#!/bin/bash


luci=package/luci/
network=package/network/

download()
{
	git clone https://github.com/openwrt/openwrt.git
	git clone https://github.com/openwrt/luci.git
	git clone https://https://github.com/openwrt/packages.git
	pushd $network
	git clone https://github.com/aa65535/openwrt-chinadns.git
	git clone https://github.com/aa65535/openwrt-dns-forwarder.git
	popd
	pushd $luci
	git clone https://github.com/techotaku/luci-app-chinadns.git
	popd
}
