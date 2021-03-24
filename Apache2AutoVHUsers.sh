#!/bin/bash
echo -e -n "SELECT FUNCTION:\\n"
echo -e -n "1) Install Service\\n"
echo -e -n "2) Add User\\n"
echo -e -n "3) Delete User\\n"
echo -e -n "4) Uninstall Service\\n"

echo -n "INSERT FUNCTION: "
read funz
echo -e "\\n"

if [ $funz = "1" ]; then
	apt-get install acl curl apache2 php libapache2-mod-php php-mysql
	apt-get install libapache2-mpm-itk
	a2enmod php*
	a2enmod mpm_itk
	systemctl restart apache2


elif [ $funz = "2" ]; then
	echo "Enter the username to INSERT: "
	read username
	if getent passwd $username > /dev/null 2>&1; then
    		echo "ERROR: THE USER ALREADY EXISTS"
	else
		adduser "$username"
		echo "USER-> $username ADDED"
		#
		curl https://git.e-fermi.it/s01723/apache2autovhusers/-/raw/master/userfiles.tgz --output /home/"$username"/userfiles.tgz
		tar xf /home/"$username"/userfiles.tgz -C /home/"$username"/
		mv /home/"$username"/defaultuser/* /home/"$username"/
		rm -r /home/"$username"/defaultuser
		rm /home/"$username"/userfiles.tgz
		#cp -r /home/defaultuser/* /home/"$username"/
		setfacl -R -m u:"$username":rwx /home/"$username"/
		setfacl -R -m o::--- /home/"$username"
		curl https://git.e-fermi.it/s01723/apache2autovhusers/-/raw/master/defaultuser.conf --output /etc/apache2/sites-available/"$username".conf
		#cp /etc/apache2/sites-available/defaultuser.conf /etc/apache2/sites-available/"$username".conf 
		sed -i "s/defaultuser/$username/" /etc/apache2/sites-available/"$username".conf
		sed -i "s/defaultuser/$username/" /etc/apache2/sites-available/"$username".conf
		a2ensite "$username"
		systemctl reload apache2
	fi
elif [ $funz = "3" ]; then
	echo -n "Enter the username to DELETE: "
	read username
	if getent passwd $username > /dev/null 2>&1; then
		a2dissite "$username"
		systemctl reload apache2
		userdel "$username"
		rm -r /home/"$username"/
		rm /etc/apache2/sites-available/"$username".conf
	else
		echo "ERROR: THE USER DOESN'T EXISTS"		
	fi
elif [ $funz = "4" ]; then
	systemctl stop apache2
	a2dismod mpm_itk
	apt-get purge libapache2-mpm-itk
	apt-get purge apache2 php libapache2-mod-php php-mysql
	echo -e -n "SERVICE UNINSTALLED\\n"
else 
	echo -e -n "Bad function selected\\n"
fi

