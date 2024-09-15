# AWS EC2 Setup (OpenGL)

Note: after the EC2 instance stop, the public IP may be changed. You need update PUBLIC_IP below with the correct one.

## Create a new EC2 instance
1. Login [aws console](https://009160038406.signin.aws.amazon.com/console)
2. Select `us-west-2` at the right upper corner
3. Input `EC2` at search
4. `Launch instances` at the right upper corner
5. Input name `gazebo-nvidia`
6. Select `Ubuntu Server 22.04 LTS`
7. Select instance type `g5.xlarge`
8. Select key pair `gazebo-keypair`
9. Network settings, select existing security group `gazebo`
10. Configure storage `48GB gp2`
11. Lanch instance

## Start / Stop EC2 instance

Note: please make sure that you **STOP** the instance after using.

1. Login [aws console](https://009160038406.signin.aws.amazon.com/console)
2. Select `us-west-2` at the right upper corner
3. Input `EC2 a` search
4. Select instances `gazebo-nvidia`
5. Select `action` -> `manage instance state` -> `start` / `stop`

## Setup ssh access

1. Download `gazebo-keypair.pem`, save to `~/.ssh/`, then `chmod 440 ~/.ssh/gazebo-keypair.pem`.
2. `ssh -i ~/.ssh/gazebo-keypair.pem ubuntu@PUBLIC_IP`

## Setup gdm3
Important, it seems tightvnc with xfce4 does not work with OpenGL.

```
sudo apt update
sudo apt upgrade
sudo apt autoremove
sudo apt autoclean
sudo apt -y install ubuntu-desktop
sudo apt -y install gdm3
sudo apt install --reinstall pkg-config cmake-data
```

Verify that gdm3 is set as the display manager

`cat /etc/X11/default-display-manager`

It should output `/usr/sbin/gdm3`.

Clear the environment.
```
sudo apt upgrade
sudo apt autoremove
sudo apt autoclean
```

## Configure X11 and GDM

- NICE DCV does not support Wayland. Disable it in `/etc/gdm3/custom.conf`

  >[Daemon]  
   WaylandEnable=false

- `sudo systemctl restart gdm3`
- Check the system boot to the desktop.

  `sudo systemctl get-default`  
  Expect the output should be `graphical.target`.  
  Otherwise, run below commands.

  ```
  sudo systemctl set-default graphical.target
  sudo systemctl isolate graphical.target
  ps aux | grep X | grep -v grep
  ```

## Install OpenGL
- `sudo apt -y install mesa-utils`

- Verify OpenGL is supported

  `sudo DISPLAY=:0 XAUTHORITY=$(ps aux | grep "X.*\-auth" | grep -v grep | sed -n 's/.*-auth \([^ ]\+\).*/\1/p') glxinfo | grep -i "opengl.*version"`

## Install Nvidia Drivers

- install aws cli
  ```
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  ```

- Configure aws cli

  `aws configure`

- Install and rebuild kernel.
  ```
  sudo apt upgrade -y linux-aws
  sudo reboot
  sudo apt install -y gcc make linux-headers-$(uname -r)
  ```

- Disable other GPU drivers.
  ```
  cat << EOF | sudo tee --append /etc/modprobe.d/blacklist.conf
  blacklist vga16fb
  blacklist nouveau
  blacklist rivafb
  blacklist nvidiafb
  blacklist rivatv
  EOF
  ```

- check the result

  `cat /etc/modprobe.d/blacklist.conf`

- disable `nouveau` in GRUB

  `sudo echo 'GRUB_CMDLINE_LINUX="rdblacklist=nouveau"' >> /etc/default/grub`

- Install Nvidia driver
  ```
  aws s3 cp --recursive s3://ec2-linux-nvidia-drivers/latest/ .
  chmod +x NVIDIA-Linux-x86_64*.run
  sudo /bin/sh ./NVIDIA-Linux-x86_64*.run
  sudo reboot
  ```

- Check the driver

  `nvidia-smi -q | head`

- Disable GSP
  ```
  sudo touch /etc/modprobe.d/nvidia.conf
  echo "options nvidia NVreg_EnableGpuFirmware=0" | sudo tee --append /etc/modprobe.d/nvidia.conf
  ```

- Remove legacy X11 configuration

  `sudo rm -rf /etc/X11/XF86Config*`

- Create new X11 configuration

  ```
  sudo nvidia-xconfig --preserve-busid --enable-all-gpus
  sudo reboot
  ```

- Check OpenGL

  `sudo DISPLAY=:0 XAUTHORITY=$(ps aux | grep "X.*\-auth" | grep -v grep | sed -n 's/.*-auth \([^ ]\+\).*/\1/p') glxinfo | grep -i "opengl.*version"`


## Install NICE DCV
- Download and Install
  ```
  wget https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY
  gpg --import NICE-GPG-KEY
  wget https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2204-x86_64.tgz
  tar -xvzf nice-dcv-ubuntu2204-x86_64.tgz
  cd nice-dcv-*-ubuntu2204-x86_64
  sudo apt install -y ./nice-dcv-server_*_amd64.ubuntu2204.deb
  sudo apt install -y ./nice-xdcv_*_amd64.ubuntu2204.deb
  sudo apt install -y ./nice-dcv-web-viewer_*_amd64.ubuntu2204.deb
  sudo usermod -aG video dcv
  sudo systemctl enable dcvserver
  ```

- Set password for user `ubuntu` with `gazebo`

  `sudo passwd ubuntu`

- Update file `/etc/dcv/dcv.conf` with below information.

  >[session-management]  
  create-session = true  
  
  [session-management/automatic-console-session]  
  owner = "ubuntu"  
  
  [connectivity]  
  quic-listen-endpoints=['0.0.0.0:8443', '[::]:8443']  
  web-listen-endpoints=['0.0.0.0:8443', '[::]:8443']
  
  enable-quic-frontend=true

- Reboot system

  `sudo reboot`

## Access DCV
Access the webpage at `https://PUBLIC_IP:8443`. (Please ignore the certificate warning)

- Command to verify OpenGL

  ```
  glxinfo
  glxgears
  ```
## Refs

- [GPU-enabled EC2](https://jeremypedersen.com/posts/2024-07-16-ubuntu-22-dcv-desktop/)
- [Nice DCV](https://aws.amazon.com/hpc/dcv/)
