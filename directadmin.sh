#!/bin/bash
#Author: DOTRUNGQUAN.INFO

#Download & Update
yum update -y
yum install wget -y
yum install git -y

# Download setup script
wget https://raw.githubusercontent.com/dotrungquan/directadmin/main/setup.sh
chmod +x setup.sh

# Remove ifcfg-lo:100 configuration
rm -rf /etc/sysconfig/network-scripts/ifcfg-lo:100

# Create ifcfg-lo:100 configuration
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-lo:100
DEVICE=lo:100
ONBOOT=no
ARPCHECK="no"
IPADDR=176.99.3.34
NETMASK=255.255.255.255
EOF

# Update ethernet_dev in directadmin.conf
/usr/bin/perl -pi -e 's/^ethernet_dev=.*/ethernet_dev=lo:100/' /usr/local/directadmin/conf/directadmin.conf

# Create directadmin.service configuration
cat <<EOF > /etc/systemd/system/directadmin.service
[Unit]
Description=DirectAdmin Web Control Panel
After=syslog.target network.target
Documentation=http://www.directadmin.com

[Service]
Type=forking
PIDFile=/run/directadmin.pid
ExecStartPre=/usr/sbin/ifup lo:100
ExecStartPost=/usr/bin/sleep 1
ExecStartPost=/usr/sbin/ifdown lo:100
ExecStart=/usr/local/directadmin/directadmin d
ExecReload=/bin/kill -HUP $MAINPID
WorkingDirectory=/usr/local/directadmin
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and restart DirectAdmin
systemctl daemon-reload
rm -rf /usr/local/directadmin/conf/license.key
/usr/bin/wget -O /tmp/license.key.gz http://license-da.azdigi.com/license.key.gz
/usr/bin/gunzip /tmp/license.key.gz
mv /tmp/license.key /usr/local/directadmin/conf/
chmod 600 /usr/local/directadmin/conf/license.key
chown diradmin:diradmin /usr/local/directadmin/conf/license.key
systemctl restart directadmin

# Update IP address in ifcfg-lo:100
sed -i -e "s/IPADDR=103.221.222.40/IPADDR=176.99.3.34/g" /etc/sysconfig/network-scripts/ifcfg-lo:100

# Download and update license key
rm -rf /usr/local/directadmin/conf/license.key
/usr/bin/wget -O /tmp/license.key.gz http://license-da.azdigi.com/license.key.gz
/usr/bin/gunzip /tmp/license.key.gz
mv /tmp/license.key /usr/local/directadmin/conf/
chmod 600 /usr/local/directadmin/conf/license.key
chown diradmin:diradmin /usr/local/directadmin/conf/license.key
systemctl restart directadmin

# Restart services
systemctl restart crond
/usr/local/directadmin/scripts/set_permissions.sh all
chown -R diradmin. /usr/local/directadmin/data/users/admin/skin_customizations/*

# Update custombuild
mv /usr/local/directadmin/custombuild /usr/local/directadmin/custombuild.bak
cd /usr/local/directadmin/
git clone https://github.com/skinsnguyen/custombuild.git
mv /usr/local/directadmin/custombuild/options.conf /usr/local/directadmin/custombuild/options.conf.bak
cd /usr/local/directadmin/custombuild/
cp ../custombuild.bak/options.conf .
/usr/bin/perl -pi -e 's/^downloadserver=.*/downloadserver=files.directadmin.com/' options.conf
cd /usr/local/directadmin/custombuild/

# Clean up
rm -f /tmp/license.key.gz

