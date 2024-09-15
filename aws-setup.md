# AWS EC2 Setup

Note: after the EC2 instance stop, the public IP may be changed. You need update it with the new value.

## setup ssh access

### Start / Stop EC2 gazebo instance
1. Login [aws console](https://009160038406.signin.aws.amazon.com/console)
2. Select us-west-2 at the right upper corner
3. Input EC2 at search
4. Select instances, select "gazebo"
5. Select "action" -> "manage instance state" -> "start" / "stop"

### ssh access
1. Download gazebo-keypair.pem, save to ~/.ssh/, then `chmod 440 ~/.ssh/gazebo-keypair.pem`.
2. `ssh -i ~/.ssh/gazebo-keypair.pem ubuntu@ec2-34-212-254-93.us-west-2.compute.amazonaws.com`

## Install VNC
```
export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt upgrade -y
sudo apt install -y xfce4 xfce4-goodies
sudo apt install -y x11-xserver-utils
sudo apt install -y tightvncserver

vncserver
# input password with `gazebo`
# select `no` for view-only
vncserver -kill :1
mv ~/.vnc/xstartup ~/.vnc/xstartup.back
```

`vi ~/.vnc/xstartup` with the below content

>#!/bin/bash  
xrdb $HOME/.Xresources  
startxfce4 &

`chmod +x ~/.vnc/xstartup`

### make vnc auto start after reboot
`sudo vi /etc/systemd/system/vncserver@1.service` with the below content

<blockquote>
[Unit]  

Description=Start TightVNC server at startup  
After=syslog.target network.target  
  
[Service]  
Type=forking  
User=ubuntu  
Group=ubuntu  
WorkingDirectory=/home/ubuntu  
  
ExecStart=/usr/bin/vncserver :1  
ExecStop=/usr/bin/vncserver -kill :1  
  
[Install]  
WantedBy=multi-user.target
</blockquote>

```
sudo systemctl daemon-reload
sudo systemctl enable vncserver@1.service
sudo systemctl start vncserver@1.service
```

### common vnc command
- start vnc server

  `vncserver :1`

- stop vnc server

  `vncserver -kill :1`

## VNC Viewer

- [tightvnc](https://remoteripple.com/download/)

  Use `ec2-34-212-254-93.us-west-2.compute.amazonaws.com` and `5901`

- [realvnc](https://www.realvnc.com/en/connect/download/viewer/macos/?lai_sr=0-4&lai_sl=l)

  Use `ec2-34-212-254-93.us-west-2.compute.amazonaws.com:1` and `5901`

## Support VNC web Viewer

```
sudo apt install apache2
sudo apt install novnc
```

`sudo vi /etc/apache2/sites-available/000-default.conf`, add these lines inside the \<VirtualHost\> block:

>Alias /novnc /usr/share/novnc  
\<Directory /usr/share/novnc\>  
&emsp;Options Indexes FollowSymLinks  
&emsp;AllowOverride None  
&emsp;Require all granted  
\</Directory\>  
ProxyPass /websockify ws://localhost:6080/websockify  
ProxyPassReverse /websockify ws://localhost:6080/websockify

Enable the proxy module in Apache
```
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo systemctl restart apache2
```

`nohup /usr/share/novnc/utils/launch.sh --vnc localhost:5901 &> novnc.log 2>&1`

Then, open the http://ec2-35-92-34-51.us-west-2.compute.amazonaws.com/novnc/vnc.html with your browser.

## Install ROS2
[ROS humble](https://docs.ros.org/en/humble/Installation.html)

### Set Locale
```
locale  # check for UTF-8

sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

locale  # verify settings
```
### Setup Sources
```
sudo apt install -y software-properties-common
sudo add-apt-repository universe
sudo apt update && sudo apt install -y curl
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
```
### Install ROS2 packages
```
sudo apt update
sudo apt upgrade
sudo apt install -y ros-humble-desktop
sudo apt install -y ros-dev-tools

echo -e "\nsource /opt/ros/humble/setup.bash" >> ~/.bashrc
```

## Install Gazebo
Ref [Compatible ROS and Gazebo](https://gazebosim.org/docs/harmonic/ros_installation/#summary-of-compatible-ros-and-gazebo-combinations) to install [GZ Fortress](https://gazebosim.org/docs/fortress/install_ubuntu/) (LTS).
```
sudo apt update
sudo apt install -y lsb-release gnupg
sudo curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
sudo apt update
sudo apt install -y ignition-fortress
```

Command to run: `ign gazebo`

## Install OpenGL
[AMD driver](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-amd-driver.html)
[Nvidia driver](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#nvidia-GRID-driver)

```
sudo apt install -y libgl1-mesa-dev libglu1-mesa-dev mesa-utils

```

## Ref

https://jeremypedersen.com/posts/2024-07-16-ubuntu-22-dcv-desktop/
