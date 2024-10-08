FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# =====================================
# [ROS2 humble](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html)
RUN locale

# Note: this will fail if install x11-apps first
RUN apt upgrade && apt update && apt install -y locales
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
# Auto setup ros env
RUN echo "source /opt/ros/humble/setup.bash" | sudo tee -a /root/.bashrc

RUN apt update && apt install -y ros-humble-moveit

# ===================GUI===================
# Tools to suppor GUI
RUN apt update && apt install -y \
    x11-apps \
    libx11-6 \
    libgtk-3-0 \
    && rm -rf /var/lib/apt/lists/*

# Set the DISPLAY environment variable
ENV DISPLAY=:0

# ===================VIM==================
RUN apt update && apt install -y vim

WORKDIR /root
