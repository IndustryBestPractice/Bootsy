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

function warn {
	YELLOW='\033[1;33m'
	NC='\033[0m' # No Color
	/bin/echo -e "${YELLOW}[]${NC}$1"
}

function info {
	BLUE='\033[0;34m'
	NC='\033[0m' # No Color
	/bin/echo -e "${BLUE}$1${NC}"
}

if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root" 
   exit 1
fi

usage="$(basename "$0") [-h] [-i /install/path] [-s] [-c /path/to/iplist.csv] [-w /path/to/wordlist] [-l /path/to/syslog/config]

where (Note: All switches are optional and you will be prompted for those you don't specify):
	-h/help         |  Display this help message
	-i/install_path |  Install path
	-s/silent       |  Silent switch. Don't prompt for validation of versions
	-c/iplist       |  IPList.csv file path
	-w/wordlist     |  Wordlist file path (adding this option stops the download of rockyou)
	-l/syslog       |  Syslog config file path (leave this option blank to load our default config)"

# Getting release version
release=`/usr/bin/lsb_release -a 2>/dev/null | grep Release | cut -d ":" -f 2 | awk '{$1=$1};1'`
# Getting kernel version
kernel=`uname -r`
# Getting PWD
start_dir=`/bin/echo $PWD`
# Getting install path
install_path=/bootsy
# Getting python version
python_version=$(/usr/bin/python3 --version 2>&1 | /usr/bin/cut -d ' ' -f 2)

# Adding input for a silent parameter so we don't bother the user if they want to run this quietly
# Parameters are added using double dashes. EX) --help
#for param in $@; do
#        if [ $param == "--help" ]; then
#                info "$usage"
#                exit 0
#        else
#                warn "Illegal parameter passed! Please see the help file!"
#                info "$usage"
#                exit 1
#        fi
#done


# Command line arguments are passed using single dashes EX) -i /bootsy
silent_param="FALSE"
while getopts ":hsicwl" opt; do
	case ${opt} in
		h | help ) info "$usage"
		    exit 0
		    ;;
		s | silent ) silent_param="TRUE"
		    ;;
		i | install_path ) install_path="$2"
		    ;;
		c | iplist ) ipList_path="$2"
		    if [ ! -f "$ipList_path" ]; then
		    	error "ipList CSV not found! Will prompt user for input"
			$ipList_path=""
		    fi
		    ;;
		w | wordlist ) wordlist_path="$2"
		    if [ ! -f "$wordlist_path" ]; then
                        error "Wordlist not found! Will prompt user for input"
                        $wordlist_path=""
                    fi
		    ;;
		l | syslog ) syslog_path="$2"
		    if [ ! -f "$syslog_path" ]; then
                        error "Syslog config not found! Will prompt user for input"
                        $syslog_path=""
                    fi
		    ;;
	        \?) error "Illegal argument passed! Please see the help file!"
		    info "$usage"
		    exit 1
		    ;;
		: ) warn "Invalid option: $OPTARG requires an argument" 1>&2
		    info "$usage"
		    exit 1
		    ;;
	esac
	shift
done
shift $((OPTIND -1))

# Testing wordfile argument
/bin/echo "Wordlist given is $wordlist_path"

exit

# Recommended software version info
recommended_release="9.9"
recommended_kernel="4.9.0-9-686"
recommended_python_version="3.5.3"

logger "Current release version: $release"
logger "Detected kernel version: $kernel"
logger "Detected start_dir: $start_dir"
logger "Detected install path: $install_path"
logger "Detected python version: $python_version"

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
/usr/bin/apt-get install -y golang-go=2:1.7~5 || respounder_error="TRUE"
logger "Building respounder"
go build -o $install_path/respounder/respounder $install_path/respounder/respounder.go || respounder_error="TRUE"

logger "Downloading artillery"
/usr/bin/git clone https://github.com/IndustryBestPractice/artillery.git
if [ -z "$wordlist_path" ]; then
	logger "Downloading rockyou"
	/usr/bin/wget https://gitlab.com/kalilinux/packages/wordlists/raw/kali/master/rockyou.txt.gz
fi

if [ ! -d "$install_path/respounder" ]; then
	error "Path variable is: $install_path/respounder"
	error "Error installing respounder!"
	respounder_error="TRUE"
fi

if [ ! -d "$install_path/artillery" ]; then
	error "Error installing artillery!"
	artillery_error="TRUE"
fi

if [ -z "$wordlist_path" ]; then
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
		logger "Renaming $start_dir/words2 to $start_dir/words"
		/bin/mv "$start_dir/words2" "$start_dir/words"
	fi
else
	logger "Removing non UTF-8 characters from $wordlist_path >> words2"
	/usr/bin/iconv -f utf-8 -t utf-8 -c "$wordlist_path" >> "$start_dir/words2"
	logger "Deleting $wordlist_path"
	/bin/rm "$wordlist_path"
	logger "Renaming $start_dir/words to $start_dir/words"
	/bin/mv "$start_dir/words2" "$start_dir/words"
fi

if [ "$respounder_error" == "TRUE" ] || [ "$artillery_error" == "TRUE" ] || [ "rockyou_error" == "TRUE" ]; then
	error "Errors occured installing respounder, artillery or RockYou! Exiting!"
	exit
fi

# Verify it is a version we're expecting
if [ $silent_param == "FALSE" ]; then
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
        if [ "$release" == "$recommended_release" ]; then
                logger "OS Release version ok!"
        else
                logger "We detected OS Release version $release!"
                logger "Our recommended version is $recommended_release, and is what this was tested on."
                logger "You may choose to continue or you can exit and install the recommended version of Linux now."
                while true; do
                        read -p "Do you want to continue? " yn
                        case $yn in
                                [Yy]* ) /bin/echo "Continuing with script!"; break;;
                                [Nn]* ) exit;;
                                * ) /bin/echo "Please enter either [Y/y] or [N/n].";;
                        esac
                done
        fi
        if [ "$kernel" == "$recommended_kernel" ]; then
                logger "OS kernel version ok!"
        else
                logger "We detected OS kernel version $kernel!"
                logger "Our recommended version is $recommended_kernel, and is what this was tested on."
                logger "You may choose to continue or you can exit and install the recommended kernel now."
                while true; do
                        read -p "Do you want to continue? " yn
                        case $yn in
                                [Yy]* ) /bin/echo "Continuing with script!"; break;;
                                [Nn]* ) exit;;
                                * ) /bin/echo "Please enter either [Y/y] or [N/n].";;
                        esac
                done
        fi
else
	logger "Detected python version is $python_version."
	logger "Recommended python version is $recommended_python_version."
	logger "Detected release version is $release."
	logger "Recommended release version is $recommended_release."
	logger "Detected kernel version is $kernel."
	logger "Recommended kernel version is $recommended_kernel."
fi

# Now that everything is installed as expected, we need to prompt for the path to the IP_LIST file.
if [ $silent_param == "FALSE" ]; then
	if [ -z $ipList_path ]; then
		logger "Please enter an accessible local or network path containing the IP CSV list file."
		logger "The format of the CSV must be:"
		logger "	ip,mask,gateway,vlanid"
		logger "	10.0.0.2,255.255.255.0,10.0.0.1,10"
		logger "	etc..."
		logger "Press enter to use default path of $start_dir/ipList.csv"
		#/bin/echo -n "Enter the path the CSV file and press [ENTER]: "
		read -p "Enter the CSV file path and press [ENTER]: " csv_path
	else
		csv_path="$ipList_path"
	fi
else
	if [ -z $ipList_path ]; then
		# Making var empty as we do a check for it below
		csv_path=""
	else
		csv_path="$ipList_path"
	fi
fi

# Now validate we can see the file

if [ -z "$csv_path" ]; then
	logger "Default path chosen!"
	csv_path="$start_dir/ipList.csv"
fi

if [ ! -f "$csv_path" ]; then
	error "File $csv_path appears to either not exist or is not reachable."
	error "Exiting setup!"
	exit 1
else
	logger "Executing python network interface setup."
	cd $start_dir
	/usr/bin/python3 "$start_dir/buildIPs.py" "$csv_path"
fi

# Now we copy the created network files in place
for MYFILE in $(ls $start_dir/ips/*)
do
	filename=`/bin/echo $MYFILE | /usr/bin/rev | /usr/bin/cut -d / -f 1 | /usr/bin/rev`
	logger "Copying $filename to /etc/network/interfaces.d"
done
/bin/cp $start_dir/ips/* /etc/network/interfaces.d/
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

