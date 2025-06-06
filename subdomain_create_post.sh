#!/bin/bash

# ENABLE ERROR LOGGING
# exec 2>/usr/local/directadmin/customscripts.error.log

# SET UP DATABASE VARIABLES
dbpass=$(openssl rand -base64 12) > /dev/null
ext=$(openssl rand -hex 2) > /dev/null
dbuser="wp${ext}"    # do not include the username_ for dataskq here as DA adds this
wpconfigdbuser="${username}_wp${ext}"
wpadminpass=$(openssl rand -base64 14) > /dev/null

# CHECK IF WORDPRESS EXISTS
if [ -f /home/$username/domains/$domain/public_html/$subdomain/index.php ]; then
    echo "WARNING: There appears to be an index file already located in this directory, which indicates that an installation is already present! Empty the directory before running the script again."
    exit
else

# DISABLE DIRECTADMIN INDEX.HTML FILE
if [ -f /home/$username/domains/$domain/public_html/$subdomain/index.html ]; then
    mv /home/$username/domains/$domain/public_html/$subdomain/index.html{,.bak}
fi

# CREATE DATABASE
/usr/bin/mysqladmin -uda_admin -p$(cat /usr/local/directadmin/conf/mysql.conf | grep pass | cut -d\= -f2 ) create ${wpconfigdbuser};
echo "CREATE USER '${wpconfigdbuser}'@'localhost' IDENTIFIED BY '${dbpass}';" | mysql -uda_admin -p$(cat /usr/local/directadmin/conf/mysql.conf | grep pass | cut -d\= -f2);
echo "GRANT ALL PRIVILEGES ON ${wpconfigdbuser}.* TO '${wpconfigdbuser}'@'localhost';" | mysql -uda_admin -p$(cat /usr/local/directadmin/conf/mysql.conf | grep pass | cut -d\= -f2);

# DOWNLOAD WORDPRESS
cd /home/$username/domains/$domain/public_html/$subdomain/
su -s /bin/bash -c "/usr/local/bin/wp core download" $username

# SET DATABASE DETAILS IN THE CONFIG FILE
su -s /bin/bash -c "/usr/local/bin/wp config create --dbname=$wpconfigdbuser --dbuser=$wpconfigdbuser --dbpass=$dbpass --dbhost=localhost" $username

# INSTALL WORDPRESS

su -s /bin/bash -c "/usr/local/bin/wp core install --url=https://$subdomain.$domain/ --admin_user=$username --admin_password=$wpadminpass --title=\"$subdomain.$domain\" --admin_email=$username@$domain" $username
su -s /bin/bash -c "/usr/local/bin/wp rewrite structure '/%postname%/'" $username
printf "\n\nWORDPRESS LOGIN CREDENTIALS:\nURL: https://$subdomain.$domain/wp-admin/\nUSERNAME: $username\nPASSWORD: $wpadminpass\n\n"


# ADD LOGIN DETAILS TO TEXT FILE
printf "\n\nWORDPRESS LOGIN CREDENTIALS:\nURL: https://$subdomain.$domain/wp-admin/\nUSERNAME: $username\nPASSWORD: $wpadminpass\n\n" >> /home/$username/domains/$domain/public_html/$subdomain/.wp-details.txt
chown $username. /home/$username/domains/$domain/public_html/$subdomain/.wp-details.txt

# DELETE DOLLY PLUGIN AND INSTALL LITESPEED CACHE
su -s /bin/bash -c "/usr/local/bin/wp plugin delete hello" $username
su -s /bin/bash -c "/usr/local/bin/wp plugin delete akismet" $username

# CREATE .HTACCESS
cat << EOF > /home/$username/domains/$domain/public_html/$subdomain/.htaccess
# BEGIN WordPress
RewriteEngine On
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
# END WordPress
EOF
chown $username. /home/$username/domains/$domain/public_html/$subdomain/.htaccess

# CHANGE FILE PERMISSIONS
cd /home/$username/domains/$domain/public_html/$subdomain/
find . -type d -exec chmod 0755 {} \;
find . -type f -exec chmod 0644 {} \;

# WORDPRESS SECURITY AND HARDENING
chmod 400 /home/$username/domains/$domain/public_html/$subdomain/.wp-details.txt
chmod 400 /home/$username/domains/$domain/public_html/$subdomain/wp-config.php

fi
exit 0;
