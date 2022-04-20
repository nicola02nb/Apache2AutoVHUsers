#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

PHOSTNAME=$HOSTNAME

PHOME=/home/
PVARTMP=/var/tmp/
PAPACHE=/etc/apache2/

TMPDIR=$PVARTMP/Apache2AutoVHUsers/

echo -e -n "SELECT FUNCTION:\\n"
echo -e -n "1) Install Service\\n"
echo -e -n "2) Add New \\ Existing User\\n"
echo -e -n "3) Disable User\\n"
echo -e -n "4) Delete User (It Delete all user's files from home)\\n"
echo -e -n "5) Uninstall Service\\n"
echo -e -n "6) Clear Temporary Files\\n"

echo -n "INSERT FUNCTION: "
read funz

if [ $funz = "1" ]; then
	echo "CHECKING AND INSTALLING MISSING DEPENDENCIES"
	apt-get install acl curl apache2 php libapache2-mod-php php-mysql
	echo "INSTALLING MOD"
	apt-get install libapache2-mpm-itk
	a2enmod php*
	a2enmod mpm_itk
	echo "RESTARTING apache2 service"
	systemctl restart apache2
	echo -e "CREATING new SYSTEM group \"VHapache2\" (ID: 1222)"
	groupadd -g 1222 VHapache2
	echo "SERVICE SUCCESFULLY INSTALLED"

elif [ $funz = "2" ]; then
	echo -n "Enter the username to INSERT: "
	read username
	if getent passwd $username > /dev/null 2>&1; then
		echo -e "INFO: THE USER ALREADY EXISTS\\n"
			
	else
		adduser --disabled-password --gecos "" "$username"
		echo -e "INFO: NEW USER \"$username\" ADDED to SYSTEM USERS\\n"	
	fi
	#
	DIR1=$TMPDIR/userfiles/
	FILE1=$TMPDIR/defaultuser.conf
	#
	echo "Downloading necessary files from Repository (https://github.com/nicola02nb/Apache2AutoVHUsers)"
	#
	if ! [ -d $TMPDIR ]; then
		echo "Creating Temporary Folder"
		mkdir $TMPDIR	
		if ! [ -d $DIR1 ]; then
			#cp ./userfiles.tar.gz $TMPDIR #USE ONLY IF YOU ARE WORKING WITH REPO
			curl -sL https://github.com/nicola02nb/Apache2AutoVHUsers/raw/dev/userfiles.tar.gz --output $TMPDIR/userfiles.tar.gz #COMMENT THIS LINE WHILE WORKING WITH REPO
			tar xf $TMPDIR/userfiles.tar.gz -C $TMPDIR --one-top-level
			rm $TMPDIR/userfiles.tar.gz
		fi
		if ! [ -f $FILE1 ] ; then
			#cp ./defaultuser.conf $TMPDIR #USE ONLY IF YOU ARE WORKING WITH REPO
			curl -sL https://github.com/nicola02nb/Apache2AutoVHUsers/raw/dev/defaultuser.conf --output $FILE1 #COMMENT THIS LINE WHILE WORKING WITH REPO
		fi
	else
		echo "No download needed, Using Temporary Files..."
	fi
	#
	cp -R $DIR1/ $PHOME/"$username"/apache2/
	mkdir $PHOME/"$username"/apache2/logs/
	setfacl -R -m u:"$username":rwx $PHOME/"$username"/
	setfacl -R -m o::--- $PHOME/"$username"
	
	cp $FILE1 $PAPACHE/sites-available/"$username".conf 
	sed -i "s/vhserverdomain/$PHOSTNAME/" $PAPACHE/sites-available/"$username".conf
	sed -i "s/defaultuser/$username/" $PAPACHE/sites-available/"$username".conf
	sed -i "s/defaultuser/$username/" $PAPACHE/sites-available/"$username".conf
	#
	echo -e "Enabling service to $username..."
	a2ensite "$username"
	echo -e "Restarting Apache2 service\\n"
	systemctl reload apache2

	usermod -a -G VHapache2 "$username"
	echo -e "USER \"$username\" added to Group VHapache2 (ID: 1222)"

elif [ $funz = "3" ]; then
	echo -n "Enter the username to DISABLE Service: "
	read username
	if getent passwd $username > /dev/null 2>&1; then
		a2dissite "$username"
		deluser "$username" VHapache2
		systemctl reload apache2
		echo -e "DISABLED VH to \"$username\"; removed form Group VHapache2 (ID: 1222)"
	else
		echo "ERROR: THE USER DOESN'T EXISTS"		
	fi

elif [ $funz = "4" ]; then
	echo -n "Enter the username to DELETE (WARNING: Deleting also all user's files): "
	read username
	if getent passwd $username > /dev/null 2>&1; then
		a2dissite "$username"
		systemctl reload apache2
		echo -e "DELETING USER HOME DIR \"$username\""
		userdel "$username"
		rm -r $PHOME/"$username"/
		rm $PAPACHE/sites-available/"$username".conf
	else
		echo "ERROR: THE USER DOESN'T EXISTS"		
	fi

elif [ $funz = "5" ]; then
	echo -n "Do you wanna Uninstall also Apache2 and PHP? [y\N]: "
	read uninstall
	a2dismod mpm_itk
	apt-get purge libapache2-mpm-itk
	systemctl reload apache2
	if [ "$uninstall" = "y" -o "$uninstall" = "Y" ]; then
		systemctl stop apache2
		apt-get purge apache2 php libapache2-mod-php php-mysql
	fi
	groupdel VHapache2
	rm -R $TMPDIR
	echo -e -n "SERVICE UNINSTALLED\\n"

elif [ $funz = "6" ]; then
	echo -e -n "Deleting Temporary Files...\\n"
	rm -r $TMPDIR
	echo -e -n "TEMPORARY FILES DELETED\\n"

else 
	echo -e -n "Bad function selected\\n"
fi

