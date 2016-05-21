#!/bin/bash -e
clear

NC='\033[0m'
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LGRAY='\033[0;37m'

echo "================================================================="
echo "Awesome WordPress Installer!!"
echo "================================================================="

# accept user input for the databse name
echo -e "${RED}Database Name: ${NC}"
read -e dbname
if [ -z "$dbname" ]; then
	echo -e "${RED}You must provide a database name, exiting.${NC}"
	exit 1
fi

echo -e "${RED}Database Username: ${NC}[root]"
read -e dbuser
if [ -z "$dbuser" ]; then
	dbuser="root"
fi

echo -e "${RED}Database Password: ${NC}[none]"
read -s dbpass

echo -e "${BLUE}WP Username [admin]: ${NC}"
read -e wpuser
if [ -z "$wpuser" ]; then
	wpuser="admin"
fi

# accept the name of our website
echo -e "${CYAN}Site Name [A WordPress Site]: ${NC}"
read -e sitename
if [ -z "$sitename" ]; then
	sitename="A WordPress Site"
fi

echo -e "${CYAN}Directory [${PWD}]: ${NC}"
echo "( This does not determine the installation folder of this directory. )"
read -e directory
if [ -z "$directory" ]; then
	directory=${PWD}
fi

echo -e "${GREEN}Domain: ${NC}"
echo "( This determines the actual folder WordPress is installed to, excluding the .ext from the domain. )"
read -e domain
if [ -z "$domain" ]; then
	echo -e "${RED}You must provide a domain excluding the http:// so something like - plugish.com${NC}"
	exit 1
fi

echo -e "${CYAN}Admin Email: ${NC}"
read -e email
if [ -z "$email" ]; then
	email="noemail@mail.net"
fi

# add a simple yes/no confirmation before we proceed
echo "Run Install? (Y/n)"
read -e run

# if the user didn't say no, then go ahead an install
if [ "$run" == n ]; then
	exit
else

	# Make the directory first, using -p will ensure it makes every directory in between.
	mkdir -p "$directory"

	# Now move to that directory
	cd "$directory"

	newdomain=$(echo "$domain" | awk -F. '{print $1}')

	mkdir -p "$newdomain"

	cd "$newdomain"

	# download the WordPress core files
	wp core download

	# create the wp-config file
	wp core config --dbname=$dbname --dbuser=$dbuser --dbpass=$dbpass

	# generate random 12 character password
	password=$(LC_CTYPE=C tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= < /dev/urandom | head -c 12)

	# create database, and install WordPress
	wp db create
	wp core install --url="http://$domain" --title="$sitename" --admin_user="$wpuser" --admin_password="$password" --admin_email="$email"

	clear

	echo "================================================================="
	echo "Installation is complete. Your username/password is listed below."
	echo ""
	echo "Username: $wpuser"
	echo "Password: $password"
	echo ""
	echo "================================================================="

fi