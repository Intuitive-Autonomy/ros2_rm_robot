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
sudo apt update
sudo apt upgrade -y
sudo apt install xfce4 xfce4-goodies -y
sudo apt install x11-xserver-utils -y
sudo apt install tightvncserver -y

vncserver
# input password with `gazebo`
# select `no` for view-only
vncserver -kill :1
mv ~/.vnc/xstartup ~/.vnc/xstartup.back
```

`vi ~/.vn/xstartup` with the below content

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

`sudo systemctl daemon-reload`

`sudo systemctl enable vncserver@1.service`

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
