#!/bin/bash
# CHECK CUSTOM PKG ITEM INSTALLWP
if [[ $installWP != 'ON' ]]; then
  exit 0;
else

# ENABLE ERROR LOGGING
# exec 2>/usr/local/directadmin/customscripts.error.log

# MOVE CONTENTS TO BACKUP FOLDER
mkdir -p /home/$username/wp-backup/$domain-backup
mv /home/$username/domains/$domain/public_html/* /home/$username/wp-backup/$domain-backup
chown -R $username. /home/$username/wp-backup

# SET UP DATABASE VARIABLES
dbpass=$(openssl rand -base64 12) > /dev/null
ext=$(openssl rand -hex 2) > /dev/null
dbuser="wp${ext}"    # do not include the username_ for dataskq here as DA adds this
wpconfigdbuser="${username}_wp${ext}"
wpadminpass=$(openssl rand -base64 14) > /dev/null

# CREATE DATABASE
/usr/bin/mysqladmin -uda_admin -p$(cat /usr/local/directadmin/conf/mysql.conf | grep pass | cut -d\= -f2 ) create ${wpconfigdbuser};
echo "CREATE USER ${wpconfigdbuser} IDENTIFIED BY '${dbpass}';" | mysql -uda_admin -p$(cat /usr/local/directadmin/conf/mysql.conf | grep pass | cut -d\= -f2 );
echo "GRANT ALL PRIVILEGES ON ${wpconfigdbuser}.* TO ${wpconfigdbuser} IDENTIFIED BY '${dbpass}';" | mysql -uda_admin -p$(cat /usr/local/directadmin/conf/mysql.conf | grep pass | cut -d\= -f2);

# DOWNLOAD WORDPRESS
cd /home/$username/domains/$domain/public_html/
su -s /bin/bash -c "/usr/local/bin/wp core download" $username

# SET DATABASE DETAILS IN THE CONFIG FILE
su -s /bin/bash -c "/usr/local/bin/wp config create --dbname=$wpconfigdbuser --dbuser=$wpconfigdbuser --dbpass=$dbpass --dbhost=localhost" $username

# INSTALL WORDPRESS
if [[ $ssl == 'ON' ]]; then
su -s /bin/bash -c "/usr/local/bin/wp core install --url=https://$domain/ --admin_user=$username --admin_password=$wpadminpass --title="$domain" --admin_email=$username@$domain " $username
su -s /bin/bash -c "/usr/local/bin/wp rewrite structure '/%postname%/'" $username
printf "\n\nWORDPRESS LOGIN CREDENTIALS:\nURL: https://$domain/wp-admin/\nUSERNAME: $username\nPASSWORD: $wpadminpass\n\n"
if [[ ! -h /home/$username/domains/$domain/private_html ]]; then
echo "Making a symlink for https..."
cd /home/$username/domains/$domain/
rm -rf private_html
su -s /bin/bash -c "ln -s public_html private_html" $username
fi
else
su -s /bin/bash -c "/usr/local/bin/wp core install --url=http://$domain/ --admin_user=$username --admin_password=$wpadminpass --title="$domain" --admin_email=$username@$domain " $username
su -s /bin/bash -c "/usr/local/bin/wp rewrite structure '/%postname%/'" $username
printf "\n\nWORDPRESS LOGIN CREDENTIALS:\nURL: http://$domain/wp-admin/\nUSERNAME: $username\nPASSWORD: $wpadminpass\n\n"
fi

# ADD LOGIN DETAILS TO TEXT FILE
printf "\n\nWORDPRESS LOGIN CREDENTIALS:\nURL: http://$domain/wp-admin/\nUSERNAME: $username\nPASSWORD: $wpadminpass\n\n" >> /home/$username/domains/$domain/public_html/.wp-details.txt
chown $username. /home/$username/domains/$domain/public_html/.wp-details.txt
fi

# DELETE DOLLY PLUGIN AND INSTALL LITESPEED CACHE
su -s /bin/bash -c "/usr/local/bin/wp plugin delete hello" $username
su -s /bin/bash -c "/usr/local/bin/wp plugin install litespeed-cache --activate" $username
#su -s /bin/bash -c "/usr/local/bin/wp plugin install litespeed-cache jetpack --activate" $username

# CREATE .HTACCESS
cat << EOF > /home/$username/domains/$domain/public_html/.htaccess
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
chown $username. /home/$username/domains/$domain/public_html/.htaccess

# CHANGE FILE PERMISSIONS
cd /home/$username/domains/$domain/public_html/
find . -type d -exec chmod 0755 {} \;
find . -type f -exec chmod 0644 {} \;

# WORDPRESS SECURITY AND HARDENING
chmod 400 /home/$username/domains/$domain/public_html/.wp-details.txt
chmod 400 /home/$username/domains/$domain/public_html/wp-config.php

fi
exit 0;
