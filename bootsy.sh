#!/bin/bash

# Brought to you by the relatively ok minds of Snorkel42, MarshallBanana, and Grubby

/bin/echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNk:..  ..:kNMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKdc,',;lkNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXl.        .lXMMMMMMMMMMMMMMMMMMMMMMMMMMNd.        ;OWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXc    .::.    lXMMMMMMMMMMMMMMMMMMMMMMMMNo.   .'.    'OWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXc    'oOOo'    lXMMMMMMMMMMMMMMMMMMMMMMNo.   .lkx:.   'OWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMWWNXXKO:    'oOKKOl.    cOKXXNWMMMMMMMMMMMMMMWXl.   .lOK0x:.   'kNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMNOoc:,'...     'oOKKKKOl.     ...';:coONWXOxdolc:;'    .lOKXK0x:.   .,;:clodkKNMMMMMMMMMMMMMMMMMMMMM
Nkdooooooooooooooool;.           .,oOKXKKKKOl'.           .',.            .lOKKKKK0x:.           .,looooooooooooooooooxK
;                       .'',;:ccldk0KKKKKKKK0xdlcc:;,''.         ....'',;cdOKXKKKKK0kl:,,'.....                        .
                       'oxkOOO0000KKK0KKK00KK00000OOOkxl'      'ldxxkkOOO00KKKKKKKKKK00OOOkkxdo:.
.                       'lxkOOOOOOOOOOOOOOOOOOOOOOOOkxl'       .cdOO000000000000000000000000Oko;.
Oc;,,,,,,,,,,,,,,,,,.    .'cdxkkkkkkkkkkkkkkkkkkkkxdc'.          'cdkkkkkkkkkkkkkkkkkkkkkkkxo;.    .,,,,,,,,,,,,,,,,,,:d
MMWWWWWWWWWWWWWWWWWWXx,    .'cddxxxxxxxxxxxxxxxxdoc'     ,xxo;.    ':oxxxxxxxxxxxxxxxxxxxdl;.    .l0WWWWWWWWWWWWWWWWWWWM
MMMMMMMMMMMMMMMMMMMMMMXx,    .:ooooooooodddddddoo;.    ,xNMMMNk;.    'cdddddddddddddddddo:.    .lKWMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMX:    ;oooooooooooooooooo,    cXMMMMMMMNk'   .;oooooooooooooooool'    :KWMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMK;   .coooooooooooooooooo:.   :XMMMMMMMMK,   .coooooooooooooooooo;    oWMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMk.   'loooooooollooooooool'   .OMMMMMMMMk.   'looooooooooooooooooc.   ;KMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMWo    ;oooool:,....,:looooo;    oWMMMMMMNl   .;ooooool:,'';cloooool'   .kMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMNc   .;ll:,..        ..,:ll;    lNMMMMMMX;   .cool:,..      .';cloo,    dWMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMWx.    ..      .;;.      ..    .kWMMMMMMNc    .''.      ..     ..''.   .kMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMWk,       .,lkXWWXkl,.      .,kWMMMMMMMMK:.        .,lkK0dc'         .dNMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMWXd;...'lONMMMMMMMMNOc'...:xXMMMMMMMMMMMXd.     .cONMMMMMWKd,.     ;kWMMMMMMMMMMMMMMMMMMMMMMMMM
                                                        Bootsy!
"

# ================================== #
# =========STATIC VARIABLES========= #
# ================================== #
# Recommended software version info
recommended_release="9.9"
recommended_kernel="4.9.0-9-686"
recommended_python_version="3.5.3"

# ================================== #
# ========DYNAMIC VARIABLES========= #
# ================================== #
# Getting release version
release=`/usr/bin/lsb_release -a 2>/dev/null | grep Release | cut -d ":" -f 2 | awk '{$1=$1};1'`
# Getting kernel version
kernel=`uname -r`
# Getting PWD
start_dir=`/bin/echo $PWD`
wordlist_path="$start_dir/funkList2000.txt"
# Getting install path
install_path=/bootsy
# Getting python version
python_version=$(/usr/bin/python3 --version 2>&1 | /usr/bin/cut -d ' ' -f 2)

if [ ! -d "$install_path" ]; then
	/bin/echo "Creating folder $install_path"
        /bin/mkdir "$install_path"
fi

function logger {
	GREEN='\033[0;32m'
	NC='\033[0m' # No Color
	/bin/echo -e "[+]$1" >> $install_path/bootsy_install.log
	/bin/echo -e "${GREEN}[+]${NC}$1"
}

function error {
	RED='\033[0;31m'
	NC='\033[0m' # No Color
	/bin/echo -e "[-]$1" >> $install_path/bootsy_install.log
	/bin/echo -e "${RED}[-]${NC}$1"
}

function warn {
	YELLOW='\033[1;33m'
	NC='\033[0m' # No Color
	/bin/echo -e "[*]$1" >> $install_path/bootsy_install.log
	/bin/echo -e "${YELLOW}[*]${NC}$1"
}

function info {
	BLUE='\033[0;34m'
	NC='\033[0m' # No Color
	/bin/echo -e "[INFO]$1" >> $install_path/bootsy_install.log
	/bin/echo -e "${BLUE}$1${NC}"
}

if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root" 
   exit 1
fi

if [ -f "$install_path/bootsy_install.log" ]; then
	/bin/rm "$install_path/bootsy_install.log" -f
	error "Removing old bootsy install file: $install_path/bootsy_install.log"
fi

#usage="$(basename "$0") [-h] [-i /install/path] [-s] [-c /path/to/iplist.csv] [-w /path/to/wordlist] [-l /path/to/syslog/config]
usage="$(basename "$0") [-h] [-i /install/path] [-c /path/to/iplist.csv] [-w /path/to/wordlist]

where (Note: All switches are optional and you will be prompted for those you don't specify):
        -h  Display this help message
        -i  Install path
        -c  IPList.csv file path
        -w  Wordlist file path (adding this option stops the download of rockyou)"

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
security_only="FALSE"
while getopts ":hi:c:w:" opt
do
	case "${opt}" in
		h ) info "$usage"
		    exit 0
		    ;;
		i ) install_path="$OPTARG"
		    ;;
		c ) ipList_path="$OPTARG"
		    if [ ! -f "$ipList_path" ]; then
		    	error "ipList CSV not found! Will prompt user for input"
			ipList_path=""
		    fi
		    ;;
		w ) wordlist_path="$OPTARG"
		    if [ ! -f "$wordlist_path" ]; then
                        error "User entered wordlist not found! Will try using funkList200 or download rockyou from OffSec"
                        wordlist_path="$start_dir/funkList2000.txt"
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
		* ) error "Unknown parameter passed! Please see the help file!"
		    info "$usage"
		    exit 1
		    ;;
	esac
done
shift $((OPTIND-1))

while [[ ! $reallysure == "y" ]] && [[ ! $reallysure == "Y" ]]; do
        #clear
        warn "This script is purpose built for a fresh install of raspbian on a raspberry pi."
        warn "This script will: "
        warn "  1) Change your hostname"
        warn "  2) Add a limited priv user"
        warn "  3) Setup key based SSH auth over an ethereal port"
        error "  4) Don't run with the silent switch...it's broken logic meant for another time..."
        warn "Are you sure you would like to continue?"
        read -p "[Y/N]? " reallysure
                case $reallysure in
                        [Yy]* ) logger "Continuing...";;
                        [Nn]* ) exit;;
                        * ) warn "Please enter either [Y/y] or [N/n].";;
                esac
done

function bootsy_check () {
	logger "Detected release version: $release"
	logger "Detected kernel version: $kernel"
	logger "Detected start_dir: $start_dir"
	logger "Detected install path: $install_path"
	logger "Detected python version: $python_version"

	/bin/echo "" #spacer
	if [ ! -d "$install_path" ]; then
		logger "Creating folder $install_path"
		/bin/mkdir "$install_path"
	fi

	cd "$install_path"

	if [ -f "/etc/rsyslog.d/99-bootsy-mail.conf" ]; then
		error "Removing old /etc/rsyslog.d/99-bootsy-mail.conf config file"
		/bin/rm "/etc/rsyslog.d/99-bootsy-mail.conf"
	fi

	if [ -f "/etc/rsyslog.d/98-bootsy-syslog.conf" ]; then
		error "Removing old /etc/rsyslog.d/98-bootsy-syslog.conf config file"
		/bin/rm "/etc/rsyslog.d/98-bootsy-syslog.conf"
	fi

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
}

function bootsy_download () {
	# Download stuff
	logger "Downloading respounder!"
	/usr/bin/git clone https://github.com/IndustryBestPractice/respounder.git
	info $rspounder

	logger "Installing Go"
	/usr/bin/apt-get install -y golang-go=2:1.7~5 || respounder_error="TRUE"
	info $rspounder_go

	logger "Building respounder"
	go build -o $install_path/respounder/respounder $install_path/respounder/respounder.go || respounder_error="TRUE"

	logger "Downloading artillery"
	/usr/bin/git clone https://github.com/IndustryBestPractice/artillery.git
	logger "Running artillery install"
	/usr/bin/python3 "$install_path/artillery/setup.py -y"

	if [ ! -f "$wordlist_path" ]; then
		error "Unable to locate $wordlist_path"
		logger "Downloading rockyou"
		/usr/bin/wget https://gitlab.com/kalilinux/packages/wordlists/raw/kali/master/rockyou.txt.gz

		if [ ! -f "$wordlist_path" ]; then
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
			logger "Renaming $start_dir/words2 to $start_dir/words"
			/bin/mv "$start_dir/words2" "$start_dir/words"
		fi
	else
		logger "Removing non UTF-8 characters from $wordlist_path >> words2"
	        /usr/bin/iconv -f utf-8 -t utf-8 -c "$wordlist_path" >> "$start_dir/words2"
	        logger "Deleting $wordlist_path"
	        /bin/rm "$wordlist_path"
	        logger "Renaming $start_dir/words2 to $start_dir/words"
		/bin/mv "$start_dir/words2" "$start_dir/words"
	fi

	/bin/echo "" #spacer
	if [ ! -d "$install_path/respounder" ]; then
	        error "Unable to find Respounder install at: $install_path/respounder"
	        error "Error installing respounder!"
	        respounder_error="TRUE"
	fi

	if [ ! -d "$install_path/artillery" ]; then
	        error "Unable to find artillery install at: $install_path/artillery"
	        error "Error installing artillery!"
	        artillery_error="TRUE"
	fi

	if [ "$respounder_error" == "TRUE" ] || [ "$artillery_error" == "TRUE" ] || [ "rockyou_error" == "TRUE" ]; then
		error "Errors occured installing respounder, artillery or wordlist! Exiting!"
		exit 1
	fi
}

function bootsy_install_logging () {
	# Prompt user for email, syslog, or both
	# email: need to ask smtp server name, from_address, to_address
	# syslog: need to ask remote host, port, UDP\TCP?
	# The 98/99 files go in: /etc/rsyslog.d
	if [ $silent_param == "FALSE" ]; then
		# Here we prompt them for what they want
		#logger "Would you like to configure email alerts for bootsy detections?"
		emailcomplete="FALSE"
	        while [ $emailcomplete == "FALSE" ]; do
			logger "Would you like to configure email alerts for bootsy detections?"
	        	read -p "[Y/N]? " email
	                case "$email" in
	        		[Yy]* ) logger "Starting email config!"; emailconfig="TRUE";;
	                        [Nn]* ) break;;
	                        * ) warn "Please enter either [Y/y] or [N/n]."; emailconfig="FALSE";;
			esac

			while [ $emailcomplete == "FALSE" ]; do
				if [ $emailconfig == "TRUE" ]; then
					read -p "What is the SMTP server name/ip? " smtp_server_name
					read -p "What is the [FROM] address? " smtp_from_address
					read -p "What is the [TO] address? " smtp_to_address

					logger "Are these options correct?"
					warn "SMTP Server: $smtp_server_name"
					warn "SMTP [FROM] Address: $smtp_from_address"
					warn "SMTP [TO] Address: $smtp_to_address"
					read -p "[Y/N]? " correct_options
					case $correct_options in
						[Yy]* ) logger "Continuing with script!"; emailcomplete="TRUE";;
						[Nn]* ) error "Enter options again..."; emailcomplete="FALSE";;
						* ) warn "Prompting for input again!";;
					esac
				else
					break
				fi
			done
		done
		/bin/echo "" #spacer
		if [ $emailcomplete == "TRUE" ]; then
			logger "Setting up email configuration..."
			logger "Updating smtp server name to [$smtp_server_name] in $start_dir/99-bootsy-mail.conf"
			/bin/sed -i "s/changeserver/$smtp_server_name/g" "$start_dir/99-bootsy-mail.conf"
			logger "Updating smtp [FROM] address to [$smtp_from_address] in $start_dir/99-bootsy-mail.conf"
			/bin/sed -i "s/bootsy@change.local/$smtp_from_address/g" "$start_dir/99-bootsy-mail.conf"
			logger "Updating smtp [TO] address to [$smtp_to_address] in $start_dir/99-bootsy-mail.conf"
			/bin/sed -i "s/to@change.local/$smtp_to_address/g" "$start_dir/99-bootsy-mail.conf"
	                logger "Copying $start_dir/99-bootsy-mail.conf to /etc/rsyslog.d"
	                /bin/cp "$start_dir/99-bootsy-mail.conf" "/etc/rsyslog.d"
		fi
		/bin/echo "" #spacer
	        #logger "Would you like to configure syslogging for bootsy detections?"
		syslogcomplete="FALSE"
	        while [ $syslogcomplete == "FALSE" ]; do
			logger "Would you like to configure syslogging for bootsy detections?"
	                read -p "[Y/N]? " syslog
	                case "$syslog" in
	                        [Yy]* ) logger "Continuing with script!"; syslogconfig="TRUE";;
	                        [Nn]* ) break;;
	                        * ) warn "Please enter either [Y/y] or [N/n]."; syslogconfig="FALSE";;
	                esac

	                while [ $syslogcomplete == "FALSE" ]; do
	                        if [ $syslogconfig == "TRUE" ]; then
	                                read -p "What is the SYSLOG remote host name/ip? " syslog_server_name
	                                read -p "What is the SYSLOG port? " syslog_port
					properprotocol="FALSE"
					while [ $properprotocol == "FALSE" ]; do
		                                read -p "What is the SYSLOG protocol [TCP/UDP]? " syslogprotocol
						case $syslogprotocol in
							[TCPtcp]* ) logger "Chose TCP!"; syslog_protocol="@@"; properprotocol="TRUE";;
							[UDPudp]* ) logger "Chose UDP!"; syslog_protocol="@"; properprotocol="TRUE";;
							* ) warn "Enter TCP or UDP!";;
						esac
					done

		                        logger "Are these options correct?"
		                        warn "SYSLOG Server: $syslog_server_name"
		                        warn "SYSLOG [PORT]: $syslog_port"
		                        warn "SYSLOG [PROTOCOL]: $syslogprotocol"
		                        read -p "[Y/N]? " correct_options
		                        case $correct_options in
		                                [Yy]* ) logger "Continuing with script!"; syslogcomplete="TRUE"; break;;
						[Nn]* ) logger "Enter options again..."; syslogcomplete="FALSE";;
		                                * ) warn "Prompting for input again!";;
		                        esac
				else
					break
				fi
	                done
	        done
	        if [ $syslogcomplete == "TRUE" ]; then
	                logger "Setting up syslog configuration..."
	                logger "Updating syslog server name to [$syslog_server_name] in $start_dir/98-bootsy-syslog.conf"
	                /bin/sed -i "s/changeserver/$syslog_server_name/g" "$start_dir/98-bootsy-syslog.conf"
	                logger "Updating syslog [PORT] to [$syslog_port] in $start_dir/98-bootsy-syslog.conf"
	                /bin/sed -i "s/changeport/$syslog_port/g" "$start_dir/98-bootsy-syslog.conf"
	                logger "Updating syslog [PROTOCOL] to [$syslogprotocol] in $start_dir/98-bootsy-syslog.conf"
	                /bin/sed -i "s/$syslog_server_name/$syslog_protocol$syslog_server_name/g" "$start_dir/98-bootsy-syslog.conf"
			logger "Copying $start_dir/98-bootsy-syslog.conf to /etc/rsyslog.d"
			/bin/cp "$start_dir/98-bootsy-syslog.conf" "/etc/rsyslog.d"
	        fi
	else
		# Here, we do defaults, because they chose silent option
		warn "Artillery will write to local syslog only!"
		warn "This is particularly useless unless you plan to config this further yourself..."
		/bin/sleep 10
	fi
}

function bootsy_install_python () {
	# Verify it is a version we're expecting
	if [ $silent_param == "FALSE" ]; then
		if [ "$python_version" == "$recommended_python_version" ]; then
			logger "Python3 version ok!"
		else
			warn "We detected Python3 version $python_version!"
			warn "Our recommended version is $recommended_python_version, and is what this was tested on."
			warn "You may choose to continue or you can exit and install the recommended version of Python3 now, and set it to the default instance."
			while true; do
				read -p "Do you want to continue? " yn
				case $yn in
					[Yy]* ) logger "Continuing with script!"; break;;
					[Nn]* ) exit;;
					* ) warn "Please enter either [Y/y] or [N/n].";;
				esac
			done
		fi
		/bin/echo "" #spacer
	        if [ "$release" == "$recommended_release" ]; then
	                logger "OS Release version ok!"
	        else
	                warn "We detected OS Release version $release!"
	                warn "Our recommended version is $recommended_release, and is what this was tested on."
	                warn "You may choose to continue or you can exit and install the recommended version of Linux now."
	                while true; do
	                        read -p "Do you want to continue? " yn
	                        case $yn in
	                                [Yy]* ) logger "Continuing with script!"; break;;
	                                [Nn]* ) exit;;
	                                * ) warn "Please enter either [Y/y] or [N/n].";;
	                        esac
	                done
	        fi
		/bin/echo "" #spacer
	        if [ "$kernel" == "$recommended_kernel" ]; then
	                logger "OS kernel version ok!"
	        else
	                warn "We detected OS kernel version $kernel!"
	                warn "Our recommended version is $recommended_kernel, and is what this was tested on."
	                warn "You may choose to continue or you can exit and install the recommended kernel now."
	                while true; do
	                        read -p "Do you want to continue? " yn
	                        case $yn in
	                                [Yy]* ) logger "Continuing with script!"; break;;
	                                [Nn]* ) exit;;
	                                * ) warn "Please enter either [Y/y] or [N/n].";;
	                        esac
	                done
	        fi
	else
		/bin/echo "" #spacer
		logger "Detected python version is $python_version."
		warn "Recommended python version is $recommended_python_version."
		logger "Detected release version is $release."
		warn "Recommended release version is $recommended_release."
		logger "Detected kernel version is $kernel."
		warn "Recommended kernel version is $recommended_kernel."
	fi
}

function bootsy_install_iplist () {
	# Now that everything is installed as expected, we need to prompt for the path to the IP_LIST file.
	if [ $silent_param == "FALSE" ]; then
		if [ -z $ipList_path ]; then
			logger "Please enter an accessible local or network path containing the IP CSV list file."
			info "The format of the CSV must be:"
			info "	ip,mask,gateway,vlanid"
			info "	10.0.0.2,255.255.255.0,10.0.0.1,10"
			info "	etc..."
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
		logger "Default path of $start_dir/ipList.csv chosen!"
		csv_path="$start_dir/ipList.csv"
	fi

	if [ ! -f "$csv_path" ]; then
		error "File $csv_path appears to either not exist or is not reachable."
		error "Exiting setup!"
		exit 1
	else
		csv_header=`/usr/bin/head -n 1 $csv_path`
		if [ $csv_header != "ip,mask,gateway,vlanid" ]; then
			error "The header of the CSV file did not match as expected!"
			error "The header we were expecting is: ip,mask,gateway,vlanid"
			error "The header we found was: $csv_header"
			error "Exiting!"
			exit 1
		fi
		logger "Executing python network interface setup."
		cd $start_dir
		#if [ ! -f "$start_dir/buildIPs.py" ]; then
		#	error "Cannot file python build file at $start_dir/buildIPs.py! Exiting
		#	exit 1
		#else
		#	/usr/bin/python3 "$start_dir/buildIPs.py" "$csv_path"
		#fi
		/usr/bin/python3 "$start_dir/buildIPs.py" "$csv_path"
	fi

	# Now we copy the created network files in place
	for MYFILE in $(ls $start_dir/ips/*)
	do
		filename=`/bin/echo $MYFILE | /usr/bin/rev | /usr/bin/cut -d / -f 1 | /usr/bin/rev`
		logger "Copying $filename to /etc/network/interfaces.d"
		#/bin/cp "$start_dir/ips/$filename" "/etc/network/interfaces.d/$filename"
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
		logger "Interface $IFACE2 will start on boot"
		#/sbin/ifup $IFACE2
	done
}

# =========================================
# ========== INSTALLING APACHE 2 ==========
# =========================================

#/usr/bin/apt-get install -y apache2=2:1.7~5 || apache2_error="TRUE"

function bootsy_security () {
	# =========================================
	# ========== SECURITY HARDENING ===========
	# =========================================
	# First we use ssh-keygen to generate public\private key pair
	#logger "Generating public\private key pair for to secure SSH..."
	#if  [ $silent_param == "TRUE" ]; then
	#	# don't prompt for passphrase
	#	keyout=`/usr/bin/ssh-keygen -f ./bootsy_rsa -t rsa -b 4096 -N ''`
	#else
	#	# prompt for passphrase
	#	read -s -p "Enter your SSH key passphrase: " pswd
	#	/bin/echo " " # giving us a space between promptin and the next line
	#	if [ -f "$start_dir/bootsy_rsa" ]; then
	#		error "Deleting $start_dir/bootsy_rsa"
	#		/bin/rm "$start_dir/bootsy_rsa"
	#	fi
	#	if [ -f "$start_dir/bootsy_rsa.pub" ]; then
	#		error "Deleting $start_dir/bootsy_rsa.pub"
	#		/bin/rm "$start_dir/bootsy_rsa.pub"
	#	fi
	#	#/bin/echo " " # giving us a space between prompting and the next line
	#	logger "Generating keygen with RSA-4096, this may take a moment..."
	#	keyout=`/usr/bin/ssh-keygen -f "$start_dir/bootsy_rsa" -t rsa -b 4096 -N '$pswd'`
	#	logger "Generation complete"
	#fi

	# Now we wait for the user to copy the SSH Key info
	#char=" "
	#num_spaces=`/bin/echo $keyout | /usr/bin/awk -F"${char}" '{print NF-1}'`
	#for i in $(seq 1 $num_spaces)
	#	do
	#		line=`/bin/echo $keyout | /usr/bin/cut -d " " -f $i`
	#		#echo "line is: $line"
	#		if [[ $line == *"SHA256"* ]]; then
	#			keyfingerprint=$line
	#		fi
	#	done
	#logger "Key Fingerprint: $keyfingerprint"
	#logger "Public Key: $start_dir/bootsy_rsa.pub"
	#logger "Private Key: $start_dir/bootsy_rsa"

	#read -p "Press [ENTER] to continue when ready... " anykey

	# Now lets add a limited permissions user
	if [ $(id -u) -eq 0 ]; then
		read -p "Enter new (limited privilege) username: " username
		read -s -p "Enter password: " password
		/bin/echo " "
		/bin/egrep "^$username" /etc/passwd >/dev/null
		if [ $? -eq 0 ]; then
			warn "$username already exists!"
			#warn "Waiting 3 seconds and trying again..."
			#/bin/sleep 3
			#return 1
			warn "Not changing the users password..."
			logger "Adding $username to sudoers group"
                        /usr/sbin/usermod -aG sudo "$username"
		else
			pass=$(/usr/bin/perl -e 'print crypt($ARGV[0], "password")' $password)
			/bin/echo " "
			/usr/sbin/useradd -m -p $pass $username
			if [ $? -eq 0 ]; then
				logger "User has been added to system!"
			else
				error "Failed to add a user!"
				return 1
			fi
			# Now create an ssh director for this user:
		#	logger "Creating /home/$username/.ssh/"
		#        /bin/mkdir "/home/$username/.ssh/" -p
		#	if [ ! -f "/home/$username/.ssh/authorized_keys file" ]; then
		#	logger "Creating empty /home/$username/.ssh/authorized_keys file"
		#	        /usr/bin/touch "/home/$username/.ssh/authorized_keys"
		#	fi
		        # Now copy our SSH keys in there and re-permission them
		#	logger "Adding $start_dir/bootsy_rsa.pub to authorized_keys file"
		#        /bin/cat "$start_dir/bootsy_rsa.pub" >> "/home/$username/.ssh/authorized_keys"
		        # Now we add the new user to the sudoers group
			logger "Adding $username to sudoers group"
		        /usr/sbin/usermod -aG sudo "$username"
		        # =======================
		        # FORCE PASSWORD CHANGE 
		        # =======================
		        #logger "You will have to change your password at next login"
		        #/usr/bin/chage -d 0 $username
		fi
                # =================
                # CHANGE HOSTNAME
                # =================
		random_3_digit=`/usr/bin/shuf --input=100-999 -n 1`
                /bin/echo "bootsy$random_3_digit" > /etc/hostname
                /bin/echo "127.0.1.1	bootsy$random_3_digit">>"/etc/hosts"
		/bin/echo "127.0.0.1    bootsy$random_3_digit">>"/etc/hosts"
                /bin/hostname "bootsy$random_3_digit"
		logger "Updating hostname to bootsy$random_3_digit"

		# ===================
		# SETUP SSH PROPERLY
		# ===================
		random_port=`/usr/bin/shuf --input=10000-30000 -n 1`
                logger "Setting SSH over port $random_port"
                /bin/sed -i "s/#Port 22/Port $random_port/g" "/etc/ssh/sshd_config"
                logger "Prohibiting root from logging in via SSH"
                /bin/sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/g" "/etc/ssh/sshd_config"
		worked="TUBULAR"
		return 0
	else
		error "Only root may add a user to the system"
		exit 1
	fi
}

function bootsy_start () {
	cron=`/usr/bin/crontab -l`
	if [ "$emailconfig" == "TRUE" ]; then
		cron_checkbootsy=`/usr/bin/crontab -l | /bin/grep "check-bootsy.sh"`
		if [ -z "$cron_checkbootsy" ]; then
	                line="* * * * * $start_dir/check-bootsy.sh"
	                (/usr/bin/crontab -u root -l; /bin/echo "$line" ) | /usr/bin/crontab -u root -
			logger "Added line to crontab: $line"
		else
			warn "check-bootsy.sh line already exists: $cron_checkbootsy"
		fi
	fi
	# Run respounder every minute
	cron_respounder=`/usr/bin/crontab -l | /bin/grep "respounder"`
	if [ -z "$cron_respounder" ]; then
		line="* * * * * $install_path/respounder/respounder -rhostname -json | /usr/bin/logger -t responder-detected"
		(/usr/bin/crontab -u root -l; /bin/echo "$line" ) | /usr/bin/crontab -u root -
		logger "Added line to crontab: $line"
	else
		warn "Respounder cron line already exists: $cron_respounder"
	fi
	# Wait 2 minutes for all services to start because rpi and start artillery
	cron_artillery=`/usr/bin/crontab -l | /bin/grep "artillery"`
	#if [ -z "$cron_artillery" ]; then
	#	line="@reboot sleep 120 && /usr/bin/python3 /var/artillery/artillery.py"
	#	(/usr/bin/crontab -u root -l; /bin/echo "$line" ) | /usr/bin/crontab -u root -
	#	logger "Added line to crontab: $line"
	#else
	#	warn "Artillery cron line already exists: $cron_artillery"
	#fi
        logger "Copying $install_path/artillery/config to /var/artillery"
        /bin/cp "$install_path/artillery/config" "/var/artillery/config"
	# Now we enable the crontab for startup
	logger "Enabling crontab on startup"
	/bin/systemctl enable cron
	# Now restart it
	logger "Restarting cron service"
	/usr/sbin/service cron restart
}

# Always do bootsy check
info "===================="
info "Checking environment"
info "===================="
bootsy_check
info "================="
info "Downloading items"
info "================="
bootsy_download
# Call bootsy function
if [ $security_only == "FALSE" ]; then
	info "=================="
	info "Setting up logging"
	info "=================="
	bootsy_install_logging
	info "======================"
	info "Validating environment"
	info "======================"
	bootsy_install_python
	info "========================"
	info "Gathering new interfaces"
	info "========================"
	bootsy_install_iplist
fi
# Call security function
worked="TOTALLY"
info "===================="
info "Setting up secure pi"
info "===================="
until [ $worked == "TUBULAR" ]
do
	bootsy_security
done
# Now we set bootsy to start on boot
bootsy_start

logger "FINISHED! GOING DOWN FOR A REBOOT IN 10 SECONDS!"
/bin/sleep 10
/sbin/shutdown -r now
