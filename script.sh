#!/usr/bin/env bash

# =============================================================
# Script created date: 10 ago 2022
# Created by: Henrique Silva (henriquesilvadotcontact@gmail.com
# Name: installphpipam
# Description: script to install phpIPAM on server
# License: GPL-3.0
# Remote repository 1: https://github.com/rick0x00/installphpipam
# Remote repository 2: https://gitlab.com/rick0x00/installphpipam

# Tested Servers:
# # Operational Sistem  - Date 
# # Debian-11.2.0-amd64 - xx ago 2022
# =============================================================

underline="________________________________________________________________";
equal="================================================================";
hash="################################################################";
plus="++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

echo "
          _           _        _ _ 
         (_)_ __  ___| |_ __ _| | |
         | |  _ \/ __| __/ _  | | |
         | | | | \__ \ || (_| | | |
         |_|_| |_|___/\__\__,_|_|_|
           __          ________  ___    __  ___
    ____  / /_  ____  /  _/ __ \/   |  /  |/  /
   / __ \/ __ \/ __ \ / // /_/ / /| | / /|_/ / 
  / /_/ / / / / /_/ // // ____/ ___ |/ /  / /  
 / .___/_/ /_/ .___/___/_/   /_/  |_/_/  /_/   
/_/         /_/                                
"


echo "$hash"
apt update
apt upgrade -y
apt autoremove -y 

echo "$hash"
apt install -y sudo vim git apache2 apache2-utils mariadb-server mariadb-client php php-cli libapache2-mod-php php-curl php-mysql php-curl php-gd php-intl php-pear php-imap php-apcu php-pspell php-tidy php-xmlrpc php-mbstring php-gmp php-json php-xml php-ldap php-common php-snmp php-fpm


echo "$hash"
git clone --recursive https://github.com/phpipam/phpipam.git /var/www/html/phpipam
cd /var/www/html/phpipam
cp config.dist.php config.php
#vim config.php


echo "$hash"
#sudo systemctl restart php*-fpm.service
systemctl enable --now mariadb
mysql_secure_installation

echo "$hash"

#mysqladmin -u root password phpipamadmin

#mysql -u root -p
#CREATE DATABASE phpipam;
#GRANT ALL ON phpipam.* TO phpipam@localhost IDENTIFIED BY 'phpipamadmin';
#FLUSH PRIVILEGES;
#QUIT;

mysql -e "CREATE DATABASE phpipam;"
mysql -e "GRANT ALL ON phpipam.* TO phpipam@localhost IDENTIFIED BY 'phpipamadmin';"
mysql -e "FLUSH PRIVILEGES;"



echo "$hash"
cd /etc/apache2/sites-enabled/
mv 000-default.conf 000-default.conf.bak
#vim /etc/apache2/sites-enabled/phpipam.conf


echo '
<VirtualHost *:80>
    ServerAdmin webmaster@local.com
    DocumentRoot "/var/www/html/phpipam"
    ServerName ipam.local.com
    ServerAlias www.ipam.local.com
    <Directory "/var/www/html/phpipam">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog "/var/log/apache2/phpipam-error_log"
    CustomLog "/var/log/apache2/phpipam-access_log" combined
</VirtualHost>
' > /etc/apache2/sites-enabled/phpipam.conf

chown -R www-data:www-data /var/www/html/

sudo apachectl -t

sudo a2enmod rewrite

systemctl restart apache2


sed -i '3 iSET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;' /var/www/html/phpipam/db/SCHEMA.sql
mysql -u root -p phpipam < /var/www/html/phpipam/db/SCHEMA.sql

echo "your default credentials Username: admin and Password: ipamadmin"

#echo "ipam.local.com" >> /etc/hosts
echo "$hash"




