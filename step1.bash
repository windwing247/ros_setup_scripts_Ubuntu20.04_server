#!/bin/bash -exv

UBUNTU_VER=$(lsb_release -sc)
ROS_VER=noetic
[ "$UBUNTU_VER" = "focal" ] || exit 1

echo "deb http://packages.ros.org/ros/ubuntu $UBUNTU_VER main" > /tmp/$$-deb
sudo mv /tmp/$$-deb /etc/apt/sources.list.d/ros-latest.list

set +vx
while ! sudo apt-get install -y curl ; do
	echo '***WAITING TO GET A LOCK FOR APT...***'
	sleep 1
done
set -vx

curl -k https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo apt-key add -
sudo apt-get update || echo ""

sudo apt-get install -y ros-${ROS_VER}-ros-base

ls /etc/ros/rosdep/sources.list.d/20-default.list && sudo rm -f /etc/ros/rosdep/sources.list.d/20-default.list
sudo apt install -y python3-pip
sudo -H pip3 install rosdep
sudo rosdep init 
sudo rosdep update

sudo apt-get install -y python3-rosinstall
sudo apt-get install -y build-essential

grep -F "source /opt/ros/$ROS_VER/setup.bash" ~/.bashrc ||
echo "source /opt/ros/$ROS_VER/setup.bash" >> ~/.bashrc

grep -F "ROS_MASTER_URI" ~/.bashrc ||
echo "export ROS_MASTER_URI=http://localhost:11311" >> ~/.bashrc

grep -F "ROS_HOSTNAME" ~/.bashrc ||
echo "export ROS_HOSTNAME=localhost" >> ~/.bashrc

sudo mkdir -p $HOME/.ros/
sudo chown $USER:$USER $HOME/.ros/ -R

### instruction for user ###
set +xv

echo '***INSTRUCTION*****************'
echo '* do the following command    *'
echo '* $ source ~/.bashrc          *'
echo '* after that, try             *'
echo '* $ LANG=C roscore            *'
echo '*******************************'

sudo apt install tree -y
sudo apt install wireless-tools -y
sudo apt install ros-noetic-cv-bridge -y
sudo apt install ros-noetic-cv-camera -y
sudo apt install ros-noetic-image-transport-plugins -y
sudo apt install ros-noetic-web-video-server -y
cd ~
git clone https://github.com/rt-net/RaspberryPiMouse.git
git clone https://github.com/Shogo4402/pimouse_setup.git
cd RaspberryPiMouse/utils
sudo apt install linux-headers-$(uname -r) build-essential
./build_install.bash
cd ~/pimouse_setup
sudo crontab crontab.conf
cd ~
sudo sed -i -e "39i dtparam=i2c_baudrate=62500" /boot/firmware/config.txt
sudo apt install ros-noetic-rt-usb-9axisimu-driver -y

cd ~/pimouse_setup
sudo crontab crontab.conf
sudo crontab -l
source ~/.bashrc
