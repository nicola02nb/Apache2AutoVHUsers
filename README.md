# VIRTUAL HOSTS APACHE2 WITH SEPARATED PERMISSIONS

This **Bash** script manages to install and manage a web-hosting service through the web-serever `apache2` with wokrking `php`
This script aims to create different **Virtual Hosts** for each single user; thanks to the **mod** for **Apache2** called `libapache2-mpm-itk`, eache **VM**
will be executed with separated and indipendent user permissions to prevent security issues:

- **Access** to other users' files trough `php`
- Use of different users permissions reather than one shared like `www-data`'s permissions

## Requirements

Dependencies required to be installed use this script `curl`:

`sudo apt install curl`

Software like `tar, apache2, php` are also needed during some steps of the installation and utilization of the service.

## Installation

To use the script just **download it** via bash command:

`curl -sL https://github.com/nicola02nb/Apache2AutoVHUsers/raw/master/Apache2AutoVHUsers.sh --output Apache2AutoVHUsers.sh`

Then you have to give it permission to **execute**:

`chmod +x ./Apache2AutoVHUsers.sh`

## Utilization

To run it just run the file `.sh`:

`sudo ./Apache2AutoVHUsers.sh`

## Compatibliliy

Installed and Tested on **Debian 10 64\32bit** server.