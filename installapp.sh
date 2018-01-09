#!/bin/bash

app=(
	vim
	git
	lm-sensors
	hddtemp	
	exuberant-ctags
	openssh-server
	subversion
	build-essential
	libncurses5-dev
	zlib1g-dev
	gawk
	ccache 
	gettext 
	libssl-dev 
	xsltproc 
	wget
	libglew-dev
	curl
	gcp	
)

app_list=""

for i in ${app[@]}
do
	app_list=${app_list}" "${i} 
done

echo $app_list

sudo tsocks apt-get update
sudo tsocks apt-get install $app_list
