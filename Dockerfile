FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# =====================================
# [ROS2 humble](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html)
RUN locale

RUN apt upgrade && apt update && apt install locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8

# verify settings
RUN locale

RUN apt update && apt install -y software-properties-common
RUN add-apt-repository universe

# =====================================
# curl
RUN apt update && apt install -y curl
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt update && apt install -y ros-humble-desktop
# RUN apt update && apt install -y gazebo
# RUN apt update && apt install -y ros-humble-gazebo-*
RUN apt update && apt install -y ros-dev-tools
# RUN source /opt/ros/humble/setup.bash

RUN apt update && apt install -y ros-humble-moveit
