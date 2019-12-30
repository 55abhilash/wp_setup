# Wordpress Installation and Configration script
This script is a single-execute Wordpress installation and configuration program. <br/>
It downloads wordpress, downloads and installs dependencies, and takes care of various configuration files; so as to get a working Wordpress
on LEMP.

This script has been tested on Ubuntu Server 19.10, Ubuntu 18.04, and Ubuntu 16.04. <br/>
Older versions might require slight adjustment according to nature of php-fpm, mysql packages.

For LEMP stack installation and configuration, the latest versions of respective packages in Ubuntu Server 19.10 are assumed. <br/>
- PHP FPM 7.3
- MySQL 8.0
- Nginx 1.16

# How to Run
`sudo ./wp_setup.sh` <br/>
Enter the domain name, MySQL password, etc. inputs as and when prompted by the script.
