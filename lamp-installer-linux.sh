#!/bin/bash

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

version="0.1 beta"        # Script version

#author info
authorName="reenekt"
authorSite="http://vk.com/reenekt"
authorEmail="thesunlightday@gmail.com"

#new WebApplication instance
WebApplicationPath="/var/www/enter_your_server_name"
WebApplicationDomain="enter_your_domain_here"

# installing Apache
installApache() {
    echo -e "${On_Blue}[INFO]${Color_Off} Installing Apache2"
    sudo apt install apache2
    if dpkg -l | grep apache2; then
        echo -e "${Green}[SUCCESS]${Color_Off} apache2 was installed"
    else
        echo -e "${Red}[ERROR]${Color_Off} apache2 was not installed"
    fi

    #todo add check - was apache2 installed?
    echo -e "${On_Blue}[INFO]${Color_Off} Checking allowed ports (80, 443)"
    if sudo ufw app info "Apache Full" | grep -e 80 -e 443; then
        echo -e "${Green}[SUCCESS]${Color_Off} apache2 was installed"
    else
        echo -e "${Red}[ERROR]${Color_Off} apache2 was not installed"

        sudo ufw app list

        sudo ufw app info "Apache Full"
    fi

    echo -e "${On_Blue}[INFO]${Color_Off} Allowing HTTP/HTTPS traffic in Apache Full"
    sudo ufw allow in "Apache Full"

    echo -e "${Green}[SUCCESS]${Color_Off} Apache was successful installed and configured!\n"
}

# installing MySQL
installMysql() {
    echo -e "${On_Blue}[INFO]${Color_Off} Installing MySQL"
    sudo apt install mysql-server
    if dpkg -l | grep mysql-server; then
        echo -e "${Green}[SUCCESS]${Color_Off} mysql-server was installed"
    else
        echo -e "${Red}[ERROR]${Color_Off} mysql-server was not installed"
    fi

    sudo mysql_secure_installation

    #todo add check 'has root set password before'
    if sudo mysql -e "SELECT user,authentication_string,plugin,host FROM mysql.user WHERE user='root';" | grep auth_socket; then
        echo -n -e "${On_Purple}[QUESTION]${Color_Off} ${BWhite}root user uses auth_socket plugin. Do you want to set mysql_native_password plugin?${Color_Off} (y/n) [n]: "
        read
        if [[ -z "$REPLY" ]]; then
            echo -e "Skipping...\n"
        elif [[ $REPLY = "y" ]]; then
           read -e -s -p "Enter new root password: " newRootPassword
           if [[ -z "$newRootPassword" ]]; then
               echo -e "${On_Yellow}[WARNING]${Color_Off} Can not set empty password. Skipping..."
           else
               sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${newRootPassword}';"
               sudo -e "FLUSH PRIVILEGES;"
               sudo mysql -e "SELECT user,authentication_string,plugin,host FROM mysql.user WHERE user='root';"
           fi
        fi
    fi

    echo -e "${Green}[SUCCESS]${Color_Off} MySQL was successful installed and configured!\n"
}

# installing PHP
phpPachageVersion() {
    if dpkg -l | grep "php7.3" -l; then
        echo -e "PHP 7.3"
    elif dpkg -l | grep "php7.2" -l; then
        echo -e "PHP 7.2"
    elif dpkg -l | grep "php7.1" -l; then
        echo -e "PHP 7.2"
    elif dpkg -l | grep "php7" -l; then
        echo -e "PHP 7"
    elif dpkg -l | grep "php5" -l; then
        echo -e "PHP 5"
    else
        echo "Unknown PHP version"
    fi
}
installPhp() {
    echo -e "${On_Blue}[INFO]${Color_Off} Installing PHP"

    sudo apt install php libapache2-mod-php php-mysql

    if dpkg -l | grep php; then
        echo -e "${Green}[SUCCESS]${Color_Off} PHP was installed"
    else
        echo -e "${Red}[ERROR]${Color_Off} PHP was not installed"
    fi

    installedPhpVersion=$(phpPachageVersion)
    echo -e "${On_Blue}[INFO]${Color_Off} Version: ${installedPhpVersion}"

    echo -n -e "${On_Purple}[QUESTION]${Color_Off} ${BWhite}Do you want to override ${UWhite}/etc/apache2/mods-enabled/dir.conf${Color_Off} (y/n) [y]: "
    read
    if [[ -z "$REPLY" ]] || [[ $REPLY = "y" ]]; then
        sudo sed -i 's/DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/g' /etc/apache2/mods-enabled/dir.conf
        echo -e "${On_Blue}[INFO]${Color_Off} ${UWhite}index.php${Color_Off} will work first after Apache restart"
        sudo systemctl restart apache2
        if sudo systemctl status apache2 | grep "active (running)"; then
            echo -e "${Green}[SUCCESS]${Color_Off} Apache restart success"
        else
            echo -e "${Red}[ERROR]${Color_Off} Apache restart failure"
        fi
        echo -e "${On_Blue}[INFO]${Color_Off} Now ${UWhite}index.php${Color_Off} will work first"
    else
        echo -e "Skipping...\n"
    fi

    echo -e "${Green}[SUCCESS]${Color_Off} PHP was successful installed and configured!\n"
}

# creating new VirtualHost
createWebApplication() {
    echo -e "${On_Blue}[INFO]${Color_Off} Creating new Web Application folder"

    read -e -i "/var/www/" -p "Enter path to your web application files (expample: /var/www/myapp.local): " WebApplicationPath
    if [[ -z "${WebApplicationPath}" ]]; then
        echo "Path cannot be empty!"
    elif [[ -d ${WebApplicationPath} ]]; then
        echo "Path ${WebApplicationPath} already exists! Skipping..."
    else
        sudo mkdir ${WebApplicationPath}
    fi

    sudo chmod -R 755 ${WebApplicationPath}

    read -p "Enter domain name (expample: myapp.local): " WebApplicationDomain
    if [[ -z "${WebApplicationDomain}" ]]; then
        echo "Path cannot be empty!"
    elif [[ -f /etc/apache2/sites-available/${WebApplicationDomain}.conf ]]; then
        echo "VirtualHost ${WebApplicationPath} already exists! Skipping..."
    else
        sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/${WebApplicationDomain}.conf
        VHSearchString="ServerAdmin webmaster@localhost"
        VirtualHostConfigData="ServerAdmin webmaster@${WebApplicationDomain}\n\tServerName ${WebApplicationDomain}\n\tServerAlias www.${WebApplicationDomain}"
        sudo sed -i "s+${VHSearchString}+${VirtualHostConfigData}+g" /etc/apache2/sites-available/${WebApplicationDomain}.conf
        VHSearchString2="DocumentRoot /var/www/html"
        VirtualHostConfigData2="DocumentRoot ${WebApplicationPath}"
        sudo sed -i "s+${VHSearchString2}+${VirtualHostConfigData2}+g" /etc/apache2/sites-available/${WebApplicationDomain}.conf
        echo -e "${On_Blue}[INFO]${Color_Off} /etc/apache2/sites-available/${WebApplicationDomain}.conf has been changed"

        sudo a2dissite 000-default.conf
        sudo a2ensite ${WebApplicationDomain}.conf

        sudo systemctl restart apache2
        if sudo systemctl status apache2 | grep "active (running)"; then
            echo -e "${Green}[SUCCESS]${Color_Off} Apache restart success"
        else
            echo -e "${Red}[ERROR]${Color_Off} Apache restart failure"
        fi
    fi

    echo -e "${Green}[SUCCESS]${Color_Off} New VirtualHost created!\n"

    echo -n -e "${On_Purple}[QUESTION]${Color_Off} ${BWhite}Do you want to create test ${UWhite}index.php${Color_Off} file in ${WebApplicationPath} (y/n) [n]: "
    read
    if [[ $REPLY = "y" ]]; then
        webServerTest  ${WebApplicationPath}
    fi
}

# testing web-server
webServerTest() {
    if [[ -n $1 ]]; then
        echo "Creating ${1} (${1%/})"
        if ls $1 | grep index.php; then
            echo -e "${On_Blue}[INFO]${Color_Off} ${UWhite}index.php${Color_Off} already created"
        else
            sudo touch ${1%/}/index.php
            sudo echo -e "<?php\n\tphpinfo();\n?>" | sudo tee ${1%/}/index.php
            echo -e "${On_Blue}[INFO]${Color_Off} ${UWhite}index.php${Color_Off} created"
        fi
    else
        echo "Path cannot be empty. Use correct syntax: webServerTest path/to/site"
    fi
}

#installing lamp stack
installLAMP() {
    echo -e "+=============== INSTALLING LAMP START ===============+"

    echo -e "${On_Blue}[INFO]${Color_Off} Updating packages"
    sudo apt update

    installApache

    installMysql

    installPhp

    echo -n -e "${On_Purple}[QUESTION]${Color_Off} ${BWhite}Do you want to create new VirtualHost (y/n) [n]: "
    read
    if [[ $REPLY = "y" ]]; then
        createWebApplication
    fi

    echo -e "+============== INSTALLING LAMP FINISHED =============+"
}

echo -e "+-----------------------------------------------------+"
echo -e "|           ${BWhite}LAMP Stack Installer by ${BCyan}${authorName}${Color_Off}           |"
echo -e "+-----------------------------------------------------+"
echo -e "Version:  ${UWhite}$version${Color_Off}"
echo -e "Author:  ${UWhite}${authorName}${Color_Off} <${authorEmail}> | ${authorSite}"

echo -e "${Yellow}ATTENTION!${Color_Off} You need superuser access to install lamp stack\n"

read -e -p "Start installing? (y/n) [n]: " startInstall
if [[ -z "$startInstall" ]]; then
    echo -e "LAMP was not installed\n"
elif [[ ${startInstall} = "y" ]]; then
   installLAMP
fi

echo -e "\n+------------------- END OF SCRIPT --------------------+\n"
