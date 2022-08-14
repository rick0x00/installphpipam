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
# # Debian-11.2.0-amd64 - 12 ago 2022
# =============================================================

underline="________________________________________________________________";
equal="================================================================";
number_sign="################################################################";
plus="++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

bigtext_install='                  _           _        _ _ 
                 (_)_ __  ___| |_ __ _| | |
                 | |  _ \/ __| __/ _  | | |
                 | | | | \__ \ || (_| | | |
                 |_|_| |_|___/\__\__,_|_|_|'
bigtext_phpipam='                  __          ________  ___    __  ___
           ____  / /_  ____  /  _/ __ \/   |  /  |/  /
          / __ \/ __ \/ __ \ / // /_/ / /| | / /|_/ / 
         / /_/ / / / / /_/ // // ____/ ___ |/ /  / /  
        / .___/_/ /_/ .___/___/_/   /_/  |_/_/  /_/   
       /_/         /_/'
bigtext_welcome='                   ___                                        
                  /\_ \
 __  __  __     __\//\ \     ___    ___     ___ ___      __   
/\ \/\ \/\ \  / __ \\ \ \   / ___\ / __ \ /  __  __ \  / __ \
\ \ \_/ \_/ \/\  __/ \_\ \_/\ \__//\ \L\ \/\ \/\ \/\ \/\  __/ 
 \ \___x___/ \ \____\/\____\ \____\ \____/\ \_\ \_\ \_\ \____\
  \/__//__/   \/____/\/____/\/____/\/___/  \/_/\/_/\/_/\/____/'
bigtext_to='                         _____    
                        |_   _|__ 
                          | |/ _ \
                          |_|\___/'

# =============================================================
# define functions

processing_error() {
    echo "$equal"
    echo ""
    echo "$*"
    echo ""
    echo "$equal"
}

presentation(){
    echo "$underline"
    echo "$bigtext_install"
    echo "$bigtext_phpipam"
    echo "$underline"
}

root_check(){
    uid=$(id -u)
    if [ $uid -ne 0 ]; then
        processing_error "Please use ROOT user for run the script."
        exit 1
    fi
}

Read_PasswdDBphpIPAM(){
    read -p "Inform Password: " PasswdDBphpIPAM
    echo "";
}

Read_CheckPasswdDBphpIPAM(){
    read -p "Confirm Password: " CheckPasswdDBphpIPAM
    echo "";
}

request_PasswdDBphpIPAM(){
    # Request password to phpIPAM database
    echo "$number_sign"
    while true ; do
        echo "$underline"
        echo "Inform password for DATABASE phpIPAM configuration!";
        echo "Or Press <ENTER> to set password as 'phpipamadmin'";
        echo "$underline"
        Read_PasswdDBphpIPAM;
        if [ -z $PasswdDBphpIPAM ]; then
            PasswdDBphpIPAM="phpipamadmin";
            echo "Password defined to 'phpipamadmin'";
            echo "$underline"
            break;
        fi
        Read_CheckPasswdDBphpIPAM;
        if [ -z $CheckPasswdDBphpIPAM ]; then
            echo "$plus"
            echo "Passwords do not match, try again!"
            echo "$plus"
        elif [ $PasswdDBphpIPAM = $CheckPasswdDBphpIPAM ]; then
            echo "Password set successfully!";
            echo "$underline"
            break;
        else
            echo "$plus"
            echo "Passwords do not match, try again!"
            echo "$plus"
        fi
    done
}

Request_Import_SCHEMAsql(){
    # funtion to choice import SCHEMA.sql from phpIPAM to DATABASE
    echo "$number_sign"
    while true ; do
        echo "$underline"
        read -p "You want to import SCHEMA.sql from phpIPAM to DATABASE? [Y/y/N/n] " ChoiceImportSCHEMAsql
        echo "$underline"
        if [ -z $ChoiceImportSCHEMAsql ]; then
            ChoiceImportSCHEMAsql="Y"
            echo "$plus"
            echo "Valid Option, import SCHEMA.sql from phpIPAM to DATABASE, lets go!"
            echo "$plus"
            break;
        elif [ $ChoiceImportSCHEMAsql = "y" -o $ChoiceImportSCHEMAsql = "y" ]; then
            echo "$plus"
            echo "Valid Option, import SCHEMA.sql from phpIPAM to DATABASE, lets go!"
            echo "$plus"
            break;
        elif [ $ChoiceImportSCHEMAsql = "N" -o $ChoiceImportSCHEMAsql = "n" ]; then
            echo "$plus"
            echo "Valid Option, do not import SCHEMA.sql from phpIPAM to DATABASE"
            echo "$plus"
            break;
        else
            echo "$plus"
            echo "Invalid Option, try again!"
            echo "$plus"
        fi
    done
}

update_upgrade_autoremove(){
    echo "$hash"
    echo "Update and Upgrade Operational System"
    echo "$plus"
    apt update
    apt upgrade -y
    apt autoremove -y 
}

install_requirements(){
    echo "$number_sign"
    echo "Install Requirements"
    echo "More Information in official site: https://phpipam.net/documents/installation/"
    echo "$plus"
    echo "Generic tools"
    echo "$plus"
    apt install -y sudo vim git 
    echo "$plus"
    echo "Apache2"
    echo "$plus"
    apt install -y apache2 apache2-utils 
    echo "$plus"
    echo "MariaDB and Mysql"
    echo "$plus"
    apt install -y mariadb-server mariadb-client
    echo "$plus"
    echo "PHP and PHP modules"
    echo "$plus"
    apt install -y php php-common php-mysql php-gmp php-crypt-gpg php-xml php-json php-cli php-mbstring php-pear php-curl php-snmp php-imap php-gd php-intl php-apcu php-pspell php-tidy php-xmlrpc php-ldap php-fpm php-file-iterator libapache2-mod-php
}

download_phpIPAM(){
    echo "$number_sign"
    echo "Download phpIPAM from github repository"
    echo "$plus"
    git clone --recursive https://github.com/phpipam/phpipam.git /var/www/phpipam
    cd /var/www/phpipam
    git checkout 1.5
    git submodule update --init --recursive
}

copy_phpIPAM_configurations(){
    echo "$number_sign"
    echo "Copy phpIPAM configurations"
    echo "$plus"
    cd /var/www/phpipam
    cp config.dist.php config.php
    # You can change phpipam default settings
    #vim config.php
}

configure_mariaDB(){
    echo "$number_sign"
    echo "Configure MariaDB Database Server"
    echo "$plus"
    systemctl enable --now mariadb
    #  Enables to improve the security of MariaDB
    #mysql_secure_installation
    # Automating `mysql_secure_installation`
    # Setting the database root password
    #mysql -e "SET PASSWORD FOR 'root'@localhost = PASSWORD("$PasswdDBphpIPAM");"
    # Make sure that NOBODY can access the server without a password
    #mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$PasswdDBphpIPAM';"
    # Delete anonymous users
    #mysql -e "DELETE FROM mysql.user WHERE User='';"
    # disallow remote login for root
    #mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    # Remove the test database
    #mysql -e "DROP DATABASE IF EXISTS test;"
    #mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
    # Make our changes take effect
    #mysql -e "FLUSH PRIVILEGES;"
    # EOF(end-of-file) IS ALTERNATIVE METHOD, MORE VERBOSE
    #mysql --user=root << EOF
    #    SET PASSWORD FOR 'root'@localhost = PASSWORD("$PasswdDBphpIPAM");
    #    ALTER USER 'root'@'localhost' IDENTIFIED BY '$PasswdDBphpIPAM';
    #    DELETE FROM mysql.user WHERE User='';
    #    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    #    DROP DATABASE IF EXISTS test;
    #    DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
    #    FLUSH PRIVILEGES;
    #EOF
}

create_database(){
    echo "$number_sign"
    echo "Create DATABASE from phpIPAM"
    echo "$plus"
    mysql -e "CREATE DATABASE phpipam;"
    mysql -e "GRANT ALL ON phpipam.* TO phpipam@localhost IDENTIFIED BY '$PasswdDBphpIPAM';"
    mysql -e "FLUSH PRIVILEGES;"
    # EOF(end-of-file) IS ALTERNATIVE METHOD
    #mysql --user=root << EOF
    #    CREATE DATABASE phpipam;
    #    GRANT ALL ON phpipam.* TO phpipam@localhost IDENTIFIED BY '$PasswdDBphpIPAM';
    #    FLUSH PRIVILEGES;
    #EOF
}

configure_apache(){
    echo "$number_sign"
    echo "Configure Apache for phpIPAM"
    echo "$plus"
    cd /etc/apache2/sites-enabled/
    mv 000-default.conf 000-default.conf.bck
    # create the virtual host for phpIPAM
    #vim /etc/apache2/sites-enabled/phpipam.conf
    echo '
    <VirtualHost *:80>
        ServerAdmin webmaster@local.com
        DocumentRoot "/var/www/phpipam"
        ServerName ipam.local.com
        ServerAlias www.ipam.local.com
        <Directory "/var/www/phpipam">
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
        ErrorLog "/var/log/apache2/phpipam-error_log"
        CustomLog "/var/log/apache2/phpipam-access_log" combined
    </VirtualHost>
    ' > /etc/apache2/sites-enabled/phpipam.conf
    # replace phpipam.local.com with your FQDN!
    chown -R www-data:www-data /var/www/

    echo "$plus"
    echo "Check syntax of the file"
    echo "$plus"
    sudo apachectl -t

    echo "$plus"
    echo "Enable the rewrite module for Apache"
    echo "$plus"
    sudo a2enmod rewrite

    echo "$plus"
    echo "Restart Apache"
    echo "$plus"
    systemctl restart apache2
}

import_SCHEMAsql(){
    if [ $ChoiceImportSCHEMAsql = "Y" -o $ChoiceImportSCHEMAsql = "y" ]; then
        echo "$number_sign"
        echo "Import SCHEMA.sql"
        echo "$plus"
        # fixes the error before import SCHEMA.sql to DATABASE
        sed -i '3 iSET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;' /var/www/phpipam/db/SCHEMA.sql
        # if the above line is not added to the SCHEMA.sql file, the import will fail!
        mysql -u root -p"$PasswdDBphpIPAM" phpipam < /var/www/phpipam/db/SCHEMA.sql
    elif [ $ChoiceImportSCHEMAsql = "N" -o $ChoiceImportSCHEMAsql = "n" ]; then
        echo "$number_sign"
        echo "Not Imported SCHEMA.sql"
        echo "$plus"
    fi
}

user_instruction(){
    echo "$number_sign"
    echo "Please use your web browser to access address."
    echo "Connect to: http://$(hostname -I)"
    echo "$number_sign"
    echo "Your default credentials to login page is:
    Username: admin
    Password: ipamadmin"
    echo "$number_sign"
}

farewell(){
    echo "$underline"
    echo "$bigtext_welcome"
    echo "$bigtext_to"
    echo "$bigtext_phpipam"
    echo "$underline"
}

# =============================================================

presentation;

root_check;

request_PasswdDBphpIPAM;

Request_Import_SCHEMAsql;

update_upgrade_autoremove;

install_requirements;

download_phpIPAM;

copy_phpIPAM_configurations;

configure_mariaDB;

create_database;

configure_apache;

import_SCHEMAsql;

farewell;

user_instruction;