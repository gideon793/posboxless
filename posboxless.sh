#!/usr/bin/env bash

apt-get update
PKGS_TO_INSTALL="adduser postgresql-client postgresql localepurge mc mg screen iw hostapd isc-dhcp-server git rsync console-data"
apt-get -y install ${PKGS_TO_INSTALL}
echo "Babel==2.3.4
chardet==3.0.4
decorator==4.0.10
docutils==0.12
ebaysdk==2.1.5
feedparser==5.2.1
gevent==1.1.2 ; sys_platform != 'win32' and python_version < '3.7'
gevent==1.3.4 ; sys_platform != 'win32' and python_version >= '3.7'
gevent==1.4.0 ; sys_platform == 'win32' and python_version >= '3.7'
greenlet==0.4.10 ; python_version < '3.7'
greenlet==0.4.13 ; python_version >= '3.7'
html2text==2016.9.19
Jinja2==2.10.1
libsass==0.12.3
lxml==3.7.1 ; sys_platform != 'win32' and python_version < '3.7'
lxml==4.2.3 ; sys_platform != 'win32' and python_version >= '3.7'
lxml ; sys_platform == 'win32'
Mako==1.0.4
MarkupSafe==0.23
mock==2.0.0
num2words==0.5.6
ofxparse==0.16
passlib==1.6.5
Pillow==4.0.0 ; python_version < '3.7'
Pillow==6.1.0 ; python_version >= '3.7'
psutil==4.3.1; sys_platform != 'win32'
psutil==5.6.3; sys_platform == 'win32'
psycopg2==2.7.3.1; sys_platform != 'win32'
psycopg2==2.8.3; sys_platform == 'win32'
pydot==1.2.3
pyldap==2.4.28; sys_platform != 'win32'
pyparsing==2.1.10
PyPDF2==1.26.0
pyserial==3.1.1
python-dateutil==2.5.3
pytz==2016.7
qrcode==5.3
reportlab==3.3.0
requests==2.20.0
suds-jurko==0.6
vatnumber==1.2
vobject==0.9.3
Werkzeug==0.11.15
XlsxWriter==0.9.3
xlwt==1.3.*
xlrd==1.0.0
pypiwin32 ; sys_platform == 'win32'
netifaces
evdev
pyusb==1.0.0b1"> requirements.txt
pip3 install -r requirements.txt


adduser pi -s /sbin/nologin -p 'raspberry'
cd /home/pi
git clone -b 12.0 --no-checkout --depth 1 https://github.com/odoo/odoo.git 
cd odoo
git config core.sparsecheckout true
echo "addons/web
addons/web_kanban
addons/hw_drivers
addons/hw_proxy
addons/hw_escpos
addons/point_of_sale/tools/posbox/configuration
odoo/
odoo-bin" | tee --append .git/info/sparse-checkout > /dev/null
git read-tree -mu HEAD


groupadd usbusers
usermod -a -G usbusers pi
usermod -a -G lp pi
usermod -a -G lpadmin pi 

sudo -u postgres createuser -s pi
mkdir /var/log/odoo
chown pi:pi /var/log/odoo

echo 'SUBSYSTEM=="usb", GROUP="usbusers", MODE="0660"
SUBSYSTEMS=="usb", GROUP="usbusers", MODE="0660"' > /etc/udev/rules.d/99-usbusers.rules

echo '[Unit]
Description=Odoo PosBoxLess
After=network.target

[Service]
Type=simple
User=pi
Group=pi
ExecStart=/home/pi/odoo/odoo-bin --load=web,hw_proxy,hw_escpos
KillMode=mixed

[Install]
WantedBy=multi-user.target

' > /etc/systemd/system/posboxless.service

systemctl enable posboxless.service
reboot
