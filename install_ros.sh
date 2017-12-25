#!/bin/bash

sudo apt-get install git

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116

sudo apt-get update

sudo apt-get install ros-indigo-desktop-full
sudo apt-get install ros-indigo-map-server
sudo apt-get install ros-indigo-sbpl

cmake_install()
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

make_install()
{
    cd $1
    make -j
    cd ../
}

install()
{
    cd $1
    sudo make install
    cd ..
}

cd ~
mkdir MyLib
cd MyLib

if [ ! -d DBoW2 ]; then
	git clone https://github.com/luckywei88/MY_DBoW2
	mv MY_DBoW2 DBoW2
	cmake_install DBoW2
fi


if [ ! -d octomap ]; then
	git clone https://github.com/luckywei88/MY_OCTOMAP
	mv MY_OCTOMAP  octomap
	cmake_install octomap
fi

if [ ! -d darknet ]; then
	git clone https://github.com/luckywei88/MY_DARKNET
	mv MY_DARKNET darknet
	make_install darknet
fi

if [ ! -d Pangolin ]; then
	git clone https://github.com/stevenlovegrove/Pangolin
	sudo apt-get install libglew-dev
	cmake_install Pangolin
	install Pangolin
fi

mkdir OriginLib
cd OriginLib

if [ ! -d ORB_SLAM2 ]; then
	git clone https://github.com/raulmur/ORB_SLAM2
	cd ORB_SLAM2
	sh build.sh
	cd ..
fi

if [ ! -d octomap ]; then
	git clone https://github.com/OctoMap/octomap
	cmake_install octomap
fi

cd ..
if [ ! -d g2o ]; then
	cd OriginLib/ORB_SLAM2/Thirdparty
	cp -r g2o .
	cmake_install g2o
fi


source /opt/ros/indigo/setup.bash
cd ~
if [ ! -d workspace ]; then
	mkdir -p workspace/src
	cd workspace
	git clone https://github.com/luckywei88/MY_SHELL
	mv MY_SHELL shell
	git clone https://github.com/luckywei88/MY_LAUNCH
	mv MY_LAUNCH launch

	cd src
	git clone https://github.com/luckywei88/MY_ORB_SLAM
	mv MY_ORB_SLAM orb_slam
	git clone https://github.com/luckywei88/my_ros_octomap
	mv my_ros_octomap octomap
	git clone https://github.com/luckywei88/MY_HUMANOID
	mv MY_HUMANOID humanoid
	catkin_init_workspace 
fi

