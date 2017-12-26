#!/bin/bash


Lib=/home/lucky/MyLib
Origin=/home/lucky/MyLib/OriginLib
work=/home/lucky/workspace/
work_src=/home/lucky/workspace/src

giturls=(
	git@github.com:luckywei88/MY_DARKNET.git
	git@github.com:luckywei88/MY_DBoW2.git
	git@github.com:luckywei88/MY_G2O.git
	git@github.com:luckywei88/MY_OCTOMAP.git
	git@github.com:luckywei88/shadowsocks.git
	git@github.com:luckywei88/MY_LAUNCH.git
	git@github.com:luckywei88/MY_SHELL.git
	git@github.com:luckywei88/MY_HUMANOID.git	
	git@github.com:luckywei88/my_ros_octomap.git
	git@github.com:luckywei88/MY_ORB_SLAM.git
)

names=(
	darknet
	DBoW2
	g2o
	octomap
	shadowsocks
	launch
	shell
	humanoid
	octomap
	orb_slam	
)

httpurls=(
	https://github.com/stevenlovegrove/Pangolin
	https://github.com/raulmur/ORB_SLAM2
	https://github.com/OctoMap/octomap	
)

get_git_name()
{
	tmp=$1
	tmp=${tmp##*/}
	tmp=${tmp%.*}
	echo $tmp
}

get_http_name()
{
	tmp=$1
	tmp=${tmp##*/}
	echo $tmp
}


ros_install()
{
	sudo apt-get update
	sudo apt-get install libglew-dev
	sudo apt-get install git
	git config --global user.name "lucky88"
	git config --global user.email "1010442593@qq.com"	

	sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
	sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
	sudo apt-get update

	sudo apt-get install ros-indigo-desktop-full
	sudo apt-get install ros-indigo-map-server
	sudo apt-get install ros-indigo-sbpl
}

git_download()
{
	if [ ! -d $3 ]; then
		git clone $1
		mv $2 $3
		cd $3
		git init
		cd ..
	fi
}

cmaking()
{
    cd $1
    if [ -d build ]; then
	rm -rf build
    fi 
    mkdir build
    cd build
    cmake ..
    make -j
    cd ../../
}

making()
{
    cd $1
    make -j
    cd ../
}


building()
{
	case $1 in
		darknet)
		making $1
		;;
		ORB_SLAM2)
		cd ORB_SLAM2
		sh build.sh
		cd ..
		;;
		shadowsocks)
		;;
		*)
		cmaking $1
		;;
	esac	
}

make_install()
{
    cd $1
    sudo make install
    cd ..
}

cd_MyDir()
{
	if [ ! -d $1 ]; then
		mkdir -p $1
	fi
	cd $1
}

install()
{
	#ros_install
	
	
	for (( i=0;i<${#httpurls[@]};i++));
	do
		url=${httpurls[$i]}
		name=$(get_http_name $url)
		echo $i" "$url" "$name
		if [ $i -le 0 ]; then
			cd_MyDir $Lib
			git_download $url $name $name
			building $name
			make_install $name 
		else 
			cd_MyDir $Origin
			building $name
			git_download $url $name $name 
		fi
	done
	
	for (( i=0;i<${#giturls[@]};i++));
	do
		url=${giturls[$i]}
		first=$(get_git_name $url)
		name=${names[$i]}
		echo $i" "$url" "$first" "$name
		if [ $i -le 4 ]; then
			cd_MyDir $Lib
			git_download $url $first $name
			building $name
		elif [ $i -le 6 ]; then
			cd_MyDir $work
			git_download $url $first $name
		else
			cd_MyDir $work_src
			git_download $url $first $name
		fi
	done
	cd_MyDir $work_src
	catkin_init_workspace 
	echo	
}

install 2>&1 | tee $0.log 
