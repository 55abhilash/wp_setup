#!/bin/bash


toInstall=()

redc="\e[31m"
greenc="\e[32m"

#1. LEMP Stack Installation
sudo apt update
sudo apt install nginx mysql-server mysql-client php php-fpm php-mysql

if [ $? -ne 0 ]
then
	echo "$redc Error in LEMP stack installation"
	exit
fi

#2. Wordpress Installation and Configuration
echo "Please Enter a domain name for the Wordpress installation"
read domain_name

#Local DNS for domain name
exhosts=`cat /etc/hosts` 
newhost="127.0.0.1 $domain_name" 
echo -e $exhosts "\n" $newhost > /etc/hosts

#Nginx Config file for Wordpress
serv_dir="server "
opbr="{\n"
clbr="}\n"
port="\tlisten 80;\n"
root="\troot /var/www/html/wordpress;\n"
ind="\tindex index.php;\n"
serv="\tserver_name $domain_name;\n"
loc="\tlocation / "
loc_sub="\t\ttry_files \$uri \$uri/ =404;\n\t$clbr"
locphp="\tlocation ~ \.php$ "
locphp_sub="\t\tfastcgi_pass unix:/run/php/php7.3-fpm.sock;\n\t\tfastcgi_index index.php;\n\t\tfastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n\t\tinclude fastcgi_params;\n\t$clbr"
echo -e $serv_dir $opbr $port $root $ind $serv $loc $opbr $loc_sub $locphp $opbr $locphp_sub $clbr > /etc/nginx/sites-available/$domain_name
sudo ln -s /etc/nginx/sites-available/$domain_name /etc/nginx/sites-enabled/

if [ $? -ne 0 ]
then
	echo "$redc Error while entering configuration for domain name"
	exit
fi

cd /var/www/html
wget http://wordpress.org/latest.zip
unzip latest.zip

if [ $? -ne 0 ]
then
	echo "$redc Error while downloading or unzipping wordpress"
	exit
fi

cd wordpress

#3. Wordpress DB Config
touch create_wp_db.sql
echo "create database \`$domain_name.db\`; create user \`wp_admin_$domain_name\`@\`localhost\` identified by 'Admin@123'; grant all privileges on \`$domain_name.db\`.* to \`wp_admin_$domain_name\`@\`localhost\`" > create_wp_db.sql
mysql -u root < create_wp_db.sql

if [ $? -ne 0 ]
then
	echo "Error in WP DB creation"
	exit
fi

cp wp-config-sample.php wp-config.php
sed -i "s/'DB_NAME', 'database_name_here'/'DB_NAME', '$domain_name.db'/g" wp-config.php
#echo "Enter MySQL DB User name:"
#read dbusername
dbusername="wp_admin_$domain_name"
sed -i "s/'DB_USER', 'username_here'/'DB_USER', '$dbusername'/g" wp-config.php
#echo "Enter Password:"
#read dbuserpass 
dbuserpass="Admin@123"
sed -i "s/'DB_PASSWORD', 'password_here'/'DB_PASSWORD', '$dbuserpass'/g" wp-config.php

if [ $? -ne 0 ]
then
	echo "$redc Error while configuring WP config file"
	exit
fi

#4. Change permissions and restart nginx
chmod -R 755 .
if [ $? -ne 0 ]
then
	echo "$redc Error while modifying permissions for wordpress folder (chmod)"
	exit
fi

service nginx restart

if [ $? -ne 0 ]
then
	echo "$redc Error while restarting nginx"
	exit
fi

rm create_wp_db.sql
cd ..
rm latest.zip

echo "$greenc Open $domain_name in the browser to check if wordpress setup is successful."
