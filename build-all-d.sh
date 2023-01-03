#!/bin/bash
#Auth:
cp /usr/local/directadmin/conf/directadmin.conf /usr/local/directadmin/conf/directadmin.conf.bak
echo > /usr/local/directadmin/conf/directadmin.conf
cat <<EOF > /usr/local/directadmin/conf/directadmin.conf
add_userdb_quota=1
apache_public_html=0
apache_ver=2.0
autoupdate=0
backup_gzip=1
brute_dos_count=100
brute_force_log_scanner=1
brute_force_scan_apache_logs=0
brute_force_time_limit=1200
brutecount=20
bruteforce=1
check_partitions=2
check_referer=0
check_subdomain_owner=1
clear_blacklist_ip_time=86400
clear_brute_log_entry_time=4
clear_brute_log_time=24
cloud_cache=0
cpu_in_system_info=0
default_private_html_link=1
demodocsroot=./data/skins/evolution
disable_ip_check=1
dkim=1
dns_ttl=1
docsroot=./data/skins/evolution
dovecot=1
enforce_difficult_passwords=0
ethernet_dev=lo:100
exempt_local_block=0
frontpage_on=0
hide_brute_force_notifications=1
http2=0
ip_brutecount=100
ipv6=1
jail=1
letsencrypt=1
litespeed=0
logs_to_keep=5
lost_password=0
mail_sni=1
max_per_email_send_limit=-1
max_username_length=10
maxfilesize=524288000
mysql_detect_correct_methods=1
nginx=0
nginx_proxy=0
ns1=ns1.directadmin.com
ns2=ns2.directadmin.com
one_click_pma_login=1
one_click_webmail_login=1
openlitespeed=0
partition_usage_threshold=95
php_fpm_max_children_default=10
pointers_own_virtualhost=1
pureftp=1
purge_spam_days=0
quota_partition=/
ram_in_system_info=0
secure_access_group=access
servername=sv.directadmin.com
session_minutes=60
ssl=0
system_user_to_virtual_passwd=1
timeout=60
unblock_brute_ip_time=86400
unified_ftp_password_file=1
update_channel=current
use_xfs_quota=1
user_brutecount=100
user_can_set_email_limit=1
webmail_link=roundcube
zip=1
zstd=0
EOF

cp /usr/local/directadmin/custombuild/options.conf /usr/local/directadmin/custombuild/options.conf.bak
echo > /usr/local/directadmin/custombuild/options.conf
cat <<EOF > /usr/local/directadmin/custombuild/options.conf
#PHP Settings
php1_release=7.4
php1_mode=mod_php
php2_release=7.3
php2_mode=php-fpm
php3_release=5.6
php3_mode=php-fpm
php4_release=5.3
php4_mode=php-fpm
secure_php=yes
php_ini=no
php_timezone=Asia/Ho_Chi_Minh
php_ini_type=production
x_mail_header=yes

#MySQL Settings
mysql=5.7
mariadb=10.4
mysql_inst=mysql
mysql_backup=yes
mysql_backup_gzip=no
mysql_backup_dir=/usr/local/directadmin/custombuild/mysql_backups
mysql_force_compile=no

#WEB Server Settings
unit=no
webserver=apache
http_methods=ALL
litespeed_serialno=trial
modsecurity=no
modsecurity_ruleset=owasp
apache_ver=2.4
apache_mpm=auto
mod_ruid2=yes
userdir_access=no
harden_symlinks_patch=yes
use_hostname_for_alias=no
redirect_host=sv.vinasoftware.com.vn
redirect_host_https=no

#WEB Applications Settings
phpmyadmin=yes
phpmyadmin_public=yes
phpmyadmin_ver=5
squirrelmail=no
roundcube=yes
webapps_inbox_prefix=no

#ClamAV-related Settings
clamav=yes
clamav_exim=yes
modsecurity_uploadscan=no
proftpd_uploadscan=no
pureftpd_uploadscan=no
suhosin_php_uploadscan=no

#Mail Settings
exim=yes
eximconf=yes
eximconf_release=4.5
blockcracking=no
easy_spam_fighter=no
spamd=spamassassin
sa_update=daily
dovecot=yes
dovecot_conf=yes
mail_compress=no
pigeonhole=yes

#FTP Settings
ftpd=pureftpd

#Statistics Settings
awstats=no
webalizer=yes

#PHP Extension Settings
#CustomBuild Settings
custombuild=2.0
custombuild_plugin=yes
autover=no
bold=yes
clean=yes
cleanapache=yes
clean_old_tarballs=yes
clean_old_webapps=yes
downloadserver=files-sg.directadmin.com
unofficial_mirrors=no

#Cronjob Settings
cron=yes
cron_frequency=daily
email=email@domain.com
notifications=no
da_autoupdate=no
updates=no
webapps_updates=no

#CloudLinux Settings
cloudlinux=no
cloudlinux_beta=no
cagefs=no

#Advanced Settings
curl=no
ssl_configuration=intermediate

#PHP extensions can be found in php_extensions.conf
redis=yes
csf=no
EOF

cd /usr/local/directadmin/custombuild
./build all d
./build rewrite_confs

systemctl restart httpd
