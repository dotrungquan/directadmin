#!/bin/bash
#Auth: DOTRUNGQUAN.INFO
echo "Downgrade Version DirectAdmin";
cd /usr/local/directadmin
mv update.tar.gz update.tar.gz.bak
wget -O update.tar.gz 'http://185.42.221.168/stable_releases_26487463753/packed_es70_64.tar.gz'
tar xvzf update.tar.gz
./directadmin p
cd scripts
./update.sh

echo "Create Card lo";
touch /etc/sysconfig/network-scripts/ifcfg-lo:100

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-lo:100
DEVICE=lo:100
ONBOOT=no
ARPCHECK="no"
IPADDR=176.99.3.34
NETMASK=255.255.255.255
EOF

echo "ethernet_dev=lo:100" >> /usr/local/directadmin/conf/directadmin.conf

echo "Create directadmin.service";
echo > /etc/systemd/system/directadmin.service
cat <<EOF > /etc/systemd/system/directadmin.service
# DirectAdmin control panel
# To reload systemd daemon after changes to this file:
# systemctl --system daemon-reload
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

systemctl daemon-reload

rm -rf /usr/local/directadmin/conf/license.key; /usr/bin/wget -O /tmp/license.key.gz https://tool.dotrungquan.info/share/directadmin/license.key.gz && /usr/bin/gunzip /tmp/license.key.gz && mv /tmp/license.key /usr/local/directadmin/conf/ && chmod 600 /usr/local/directadmin/conf/license.key && chown diradmin:diradmin /usr/local/directadmin/conf/license.key && systemctl restart directadmin

echo "Disable ipv6";
sed -i 's/ipv6=1/ipv6=0/g'  /usr/local/directadmin/conf/directadmin.conf
echo "ipv6=0" >> /usr/local/directadmin/conf/directadmin.conf

echo "Restart Directadmin";
systemctl enable directadmin && systemctl restart directadmin
