# VIRTUAL HOSTS APACHE2 WITH SEPARATED PERMISSIONS

This **Bash** script manages to install and manage a web-hosting service through the web-serever `apache2` with wokrking `php`
This script aims to create different **Virtual Hosts** for each single user; thanks to the **mod** for **Apache2** called `libapache2-mpm-itk`, eache **VM**
will be executed with separated and indipendent user permissions to prevent security issues:

- **Access** to other users' files trough `php`
- Use of different users permissions reather than one shared like `www-data`'s permissions

## Installation

Installed and Tested on **DEBIAN 10 64\32bit** server

Dependencies required for use `curl, apache2`:

`sudo apt install curl`

To use the script just **download it** via:

`curl https://git.e-fermi.it/s01723/apache2autovhusers/-/raw/master/Apache2AutoVHUsers.sh --output Apache2AutoVHUsers.sh`

Then you have to give it permission to **execute**:

`chmod +x ./Apache2AutoVHUsers.sh`

## Utilization

To run it just run the file `.sh`:

`./Apache2AutoVHUsers.sh`
