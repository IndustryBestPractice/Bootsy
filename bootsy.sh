#!/bin/bash

function logger {
	GREEN='\033[0;32m'
	NC='\033[0m' # No Color
	/bin/echo -e "${GREEN}[+]${NC}$1"
}

function error {
	RED='\033[0;31m'
	NC='\033[0m' # No Color
	/bin/echo -e "${RED}[-]${NC}$1"
}

if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root" 
   exit 1
fi

# Set install path
start_dir=`/bin/echo $PWD`
install_path=/bootsy
recommended_python_version="3.5.3"

if [ ! -d "$install_path" ]; then
	logger "Creating folder $install_path"
	/bin/mkdir "$install_path"
fi

cd "$install_path"

if [ -d "$install_path/respounder" ]; then
	error "Removing old folder $install_path/respounder"
	/bin/rm "$install_path/respounder" -rf
fi

if [ -d "$install_path/artillery" ]; then
	error "Removing old folder $install_path/artillery"
	/bin/rm "$install_path/artillery" -rf
fi

# Check for the rockyou.txt wordlist
if [ -f "$install_path/rockyou.txt.gz" ]; then
	error "Removing old rockyou wordlist from $install_path/rockyou.txt.gz"
	/bin/rm "$install_path/rockyou.txt.gz" -rf
fi

if [ -f "$install_path/words" ]; then
	error "Removing old words file from $install_path/words"
	/bin/rm "$install_path/words"
fi

if [ -f "$start_dir/words" ]; then
	error "Removing old words file from $start_dir/words"
	/bin/rm "$start_dir/words"
fi

# Download stuff
logger "Downloading respounder!"
/usr/bin/git clone https://github.com/IndustryBestPractice/respounder.git
# Still need to unzip the package here....
logger "Installing Go"
apt-get install -y golang-go || respounder_error="TRUE"
logger "Building respounder"
go build -o $install_path/respounder/respounder $install_path/respounder/respounder.go || respounder_error="TRUE"

logger "Downloading artillery"
/usr/bin/git clone https://github.com/IndustryBestPractice/artillery.git
logger "Downloading rockyou"
/usr/bin/wget https://gitlab.com/kalilinux/packages/wordlists/raw/kali/master/rockyou.txt.gz

if [ ! -d "$install_path/respounder" ]; then
	error "Path variable is: $install_path/respounder"
	error "Error installing respounder!"
	respounder_error="TRUE"
fi

if [ ! -d "$install_path/artillery" ]; then
	error "Error installing artillery!"
	artillery_error="TRUE"
fi

if [ ! -f "$install_path/rockyou.txt.gz" ]; then
	error "Error downloading rockyou!"
	rockyou_error="TRUE"
else
	logger "Moving rockyou.txt.gz to $start_dir"
	/bin/mv rockyou.txt.gz $start_dir
	logger "Unzipping rockyou..."
	/bin/gunzip "$start_dir/rockyou.txt.gz"
	logger "Moving $start_dir/rockyou.txt to $start_dir/words"
	/bin/mv "$start_dir/rockyou.txt" "$start_dir/words"
	# Removing non UTF8 characters
	logger "Removing non UTF-8 characters from words >> words2"
	/usr/bin/iconv -f utf-8 -t utf-8 -c "$start_dir/words" >> "$start_dir/words2"
	logger "Deleting $start_dir/words"
	/bin/rm "$start_dir/words"
	logger "Renaming $start_dir/words2 $start_dir/words"
	/bin/mv "$start_dir/words2" "$start_dir/words"
fi

if [ "$respounder_error" == "TRUE" ] || [ "$artillery_error" == "TRUE" ] || [ "rockyou_error" == "TRUE" ]; then
	error "Errors occured installing respounder, artillery or RockYou! Exiting!"
	exit
fi

# Get python version
logger "Getting python version..."
python_version=$(/usr/bin/python3 --version 2>&1 | /usr/bin/cut -d ' ' -f 2)

# Verify it is a version we're expecting
if [ "$python_version" == "$recommended_python_version" ]; then
	logger "Python3 version ok!"
else
	logger "We detected Python3 version $python_version!"
	logger "Our recommended version is $recommended_python_version, and is what this was tested on."
	logger "You may choose to continue or you can exit and install the recommended version of Python3 now, and set it to the default instance."
	while true; do
		read -p "Do you want to continue? " yn
		case $yn in
			[Yy]* ) /bin/echo "Continuing with script!"; break;;
			[Nn]* ) exit;;
			* ) /bin/echo "Please enter either [Y/y] or [N/n].";;
		esac
	done
fi

# Now that everything is installed as expected, we need to prompt for the path to the IP_LIST file.
logger "Please enter an accessible local or network path containing the IP CSV list file."
logger "The format of the CSV must be:"
logger "	ip,mask,gateway,vlanid"
logger "	10.0.0.2,255.255.255.0,10.0.0.1,10"
logger "	etc..."
/bin/echo -n "Enter the path the CSV file and press [ENTER]: "
read csv_path

# Now validate we can see the file

if [ ! -f "$csv_path" ]; then
	error "File $csv_path appears to either not exist or is not reachable."
	error "Exiting setup!"
	exit
else
	logger "Executing python network interface setup."
	cd $start_dir
	/usr/bin/python3 "$start_dir/buildIPs.py" "$csv_path"
fi

# Now we copy the created network files in place
/bin/cp "$start_dir/ips/*" "/etc/network/interfaces.d"
# Now we start each of the interfaces
for IFACE in $(ls /etc/network/interfaces.d/*-*)
do
	#echo "Checking file $IFACE"
	interface_name=`/bin/echo $IFACE | /usr/bin/rev | /usr/bin/cut -d / -f 1 | /usr/bin/rev`
	#echo "interface name is $interface_name"
	IFACE2=`/bin/echo $interface_name | /usr/bin/awk -F "-" '{print $1 ":" $2}'`
	#echo "parsed name is $IFACE2"
	#echo $IFACE2
	logger "Starting interface adapter: $IFACE2"
	#/sbin/ifup $IFACE2
done
