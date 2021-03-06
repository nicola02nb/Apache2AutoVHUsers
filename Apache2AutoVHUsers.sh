#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# sudo ./Apache2AutoVHUsers.sh [ -1|-5|-6 ] | [ -2|-3|-4 [ 'username' 'password' ] | [ --list-file '/file/path/*.txt' ] ]

#######################
#File (.txt) Example: #
#Line # 			
#######################
	#1#
	#2#	utente1, utente2, utente3, utente4, utente5,
	#3# utente6,
	#4#
	#5# utente7, utente8, utente9,
	#6# utente10, etc ...
	#7#
	#8#
	#9#
	###


### EDITABLE VARIABLES TO ADAPT TO YOUR ENVIROMENT ###

#PHOSTNAME=$HOSTNAME

PHOME=/home/
PVARTMP=/var/tmp/
PAPACHE=/etc/apache2/

TMPDIR=$PVARTMP/Apache2AutoVHUsers/						
######################################################

funz=""
listfile=""
username=""
defaultpassword="defaultpassword"
grouname="VHapache2"
groupid="1222"

echo -e -n "SELECT FUNCTION:\\n"
echo -e -n "1) Install Service\\n"
echo -e -n "2) Add New \\ Existing User\\n"
echo -e -n "3) Disable User\\n"
echo -e -n "4) Delete User (It Delete all user's files from home, and his database)\\n"
echo -e -n "5) Uninstall Service\\n"
echo -e -n "6) Clear Temporary Files\\n"
echo -e -n "7) Show Service-Installed Users\\n\\n"

if [ "$1" = "-1" ] || [ "$1" = "-5" ] || [ "$1" = "-6" ] || [ "$1" = "-7" ]; then
	funz="${1: 1:1}"
elif [ "$1" = "-2" ] || [ "$1" = "-3" ] || [ "$1" = "-4" ]; then
	funz="${1: 1:1}"
	if [ "$2" = "--list-file" ]; then
		listfile="$3"
	else 
		username="$2"
		if ! [ "$3" = "" ]; then
			defaultpassword="$3"
		fi
	fi
else
	echo -n "INSERT FUNCTION: "
	read funz
fi

if [ "$funz" = "1" ]; then
	echo "----- INSTALLING SERVICE -----"
	echo "CHECKING AND INSTALLING MISSING DEPENDENCIES"
	apt-get -y install acl curl apache2 php libapache2-mod-php php-mysql mariadb-server
	echo "INSTALLING MOD"
	apt-get -y install libapache2-mpm-itk
	a2enmod php*
	a2enmod mpm_itk
	echo "RESTARTING apache2 service"
	systemctl restart apache2
	echo -e "CREATING new SYSTEM group \"$grouname\" (ID: $groupid)"
	groupadd -g $groupid $grouname
	echo "SERVICE SUCCESFULLY INSTALLED"

elif [ "$funz" = "2" ]; then
	echo "----- ENABLING USER -----"
	while [ "$username" = "" ]; do
		echo -n "Enter the username to INSERT (CANNOT BE EMPTY): "
		read username
	done
	if getent passwd $username > /dev/null 2>&1; then
		echo -e "INFO: THE USER ALREADY EXISTS\\n"
			
	else
		adduser --disabled-password --gecos "" "$username"
		echo "$username:$defaultpassword" | chpasswd
		echo -e "\\nINFO: NEW USER \"$username\" ADDED to SYSTEM USERS\\n"	
	fi
	#
	DIR1=$TMPDIR/userfiles/
	FILE1=$TMPDIR/defaultuser.conf
	#
	echo -e -n  "Downloading necessary files from Repository (https://github.com/nicola02nb/Apache2AutoVHUsers)\\n"
	#
	if ! [ -d $TMPDIR ]; then
		echo "Creating Temporary Folder"
		mkdir $TMPDIR	
		if ! [ -d $DIR1 ]; then
			#cp ./userfiles.tar.gz $TMPDIR #USE ONLY IF YOU ARE WORKING WITH REPO
			curl -sL https://github.com/nicola02nb/Apache2AutoVHUsers/raw/master/userfiles.tar.gz --output $TMPDIR/userfiles.tar.gz #COMMENT THIS LINE WHILE WORKING WITH REPO
			tar xf $TMPDIR/userfiles.tar.gz -C $TMPDIR --one-top-level
			rm $TMPDIR/userfiles.tar.gz
		fi
		if ! [ -f $FILE1 ] ; then
			#cp ./defaultuser.conf $TMPDIR #USE ONLY IF YOU ARE WORKING WITH REPO
			curl -sL https://github.com/nicola02nb/Apache2AutoVHUsers/raw/master/defaultuser.conf --output $FILE1 #COMMENT THIS LINE WHILE WORKING WITH REPO
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
	#sed -i "s/vhserverdomain/$PHOSTNAME/" $PAPACHE/sites-available/"$username".conf
	sed -i "s/defaultuser/$username/" $PAPACHE/sites-available/"$username".conf
	sed -i "s/defaultuser/$username/" $PAPACHE/sites-available/"$username".conf
	#
	echo -e "Enabling service to $username..."
	a2ensite "$username"
	echo -e "Restarting Apache2 service\\n"
	systemctl reload apache2

	usermod -a -G $grouname "$username"
	echo -e "USER \"$username\" added to Group $grouname (ID: $groupid)"
	echo "Creating database for $username...."
	mysql -u root -e "CREATE database $username;"
	mysql -u root -e "CREATE USER '$username'@localhost IDENTIFIED BY '$defaultpassword';"
	mysql -u root -e "GRANT ALL PRIVILEGES ON $username.* TO '$username'@localhost;"
	mysql -u root -e "FLUSH PRIVILEGES;"

elif [ "$funz" = "3" ]; then
	echo "----- DISABLING USER SERVICE -----"
	while [ "$username" = "" ]; do
		echo -n "Enter the username to DISABLE (CANNOT BE EMPTY): "
		read username
	done
	if getent passwd $username > /dev/null 2>&1; then
		a2dissite "$username"
		deluser "$username" $grouname
		systemctl reload apache2
		echo -e "DISABLED VH to \"$username\"; removed form Group $grouname (ID: $groupid)"
	else
		echo "ERROR: THE USER DOESN'T EXISTS"		
	fi

elif [ "$funz" = "4" ]; then
	echo "----- DELETING USER -----"
	while [ "$username" = "" ]; do
		echo -n "Enter the username to DELETE (CANNOT BE EMPTY): "
		read username
	done
	if getent passwd $username > /dev/null 2>&1; then
		a2dissite "$username"
		systemctl reload apache2
		echo -e "DELETING USER HOME DIR \"$username\""
		userdel "$username"
		rm -r $PHOME/"$username"/
		rm $PAPACHE/sites-available/"$username".conf
		echo -e "DELETING USER Database"
		mysql -u root -e "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '$username'@'localhost';"
		mysql -u root -e "DROP USER IF EXISTS '$username'@'localhost';"
		mysql -u root -e "DROP database IF EXISTS $username;"
		mysql -u root -e "FLUSH PRIVILEGES;"
	else
		echo "ERROR: THE USER DOESN'T EXISTS"		
	fi

elif [ "$funz" = "5" ]; then
	echo "----- UNINSTALLING SERVICE -----"
	echo -n "Do you wanna Uninstall also Apache2, PHP and MariaDB? [y\N]: "
	read uninstall
	a2dismod mpm_itk
	apt-get -y purge libapache2-mpm-itk
	systemctl reload apache2
	if [ "$uninstall" = "y" -o "$uninstall" = "Y" ]; then
		systemctl stop apache2
		apt-get -y purge apache2 php libapache2-mod-php php-mysql mariadb-server
		rm -R /etc/apache2/
	fi
	groupdel $grouname
	rm -R $TMPDIR
	echo -e -n "SERVICE UNINSTALLED\\n"

elif [ "$funz" = "6" ]; then
	echo -e -n "----- DELETING TEMPORARY FILES -----\\n"
	rm -r $TMPDIR
	echo -e -n "TEMPORARY FILES DELETED\\n"

elif [ "$funz" = "7" ]; then
	nchar=$( expr ${#grouname} + ${#groupid} + 4 )
	echo -e -n "----- SHOWING SERVICE-INSTALLED USERS -----\\n"
	tstr=$(getent group "$grouname")
	str=${tstr: nchar}
	IFS=',' read -ra ADDR <<< "$str"
	for i in "${ADDR[@]}"; do
		if [ -f "$PAPACHE/sites-enabled/$i.conf" ]; then
			echo "$i : config enabled"
		elif [ -f "$PAPACHE/sites-available/$i.conf" ]; then
			echo "$i : config disabled"
		elif [ -d "$PHOME/$i/" ]; then
			echo "$i : only home found"
		else
			echo "$i : -"
		fi
	done
	echo -e -n "----- LIST END ---\\n"

else 
	echo -e -n "----- BAD FUNCTION SELECTED -----\\n"
fi

