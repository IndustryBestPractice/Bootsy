#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Run as whatever the current logged in user is
# Set install path
start_dir=`echo $PWD`
install_path=/bootsy
recommended_python_version="3.5.3"

if [ ! -d "$install_path" ]; then
	echo "[+]Creating folder $install_path"
	mkdir "$install_path"
fi

cd "$install_path"

if [ -d "$install_path/respounder" ]; then
	echo "[+]Removing old folder $install_path/respounder"
	rm "$install_path/respounder" -rf
fi

if [ -d "$install_path/artillery" ]; then
	echo "[+]Removing old folder $install_path/artillery"
	rm "$install_path/artillery" -rf
fi

# Check for the rockyou.txt wordlist
if [ -f "$install_path/rockyou.txt.gz" ]; then
	echo "[+]Removing old rockyou wordlist"
	rm "$install_path/rockyou.txt.gz" -rf
fi

if [ -f "$install_path/words" ]; then
	echo "[+]Removing old words file"
	rm "$install_path/words"
fi

if [ -f "$start_dir/words" ]; then
	echo "[+]Removing old words file from $start_dir"
	rm "$start_dir/words"
fi

# Download stuff
echo "[+]Downloading respounder!"
git clone https://github.com/IndustryBestPractice/respounder.git
# Still need to unzip the package here....
echo "[+]Downloading artillery"
git clone https://github.com/IndustryBestPractice/artillery.git
echo "[+]Downloading rockyou"
wget https://gitlab.com/kalilinux/packages/wordlists/raw/kali/master/rockyou.txt.gz

if [ ! -d "$install_path/respounder" ]; then
	echo "[+]Path variable is: $install_path/respounder"
	echo "[+]Error installing respounder!"
	respounder_error="TRUE"
fi

if [ ! -d "$install_path/artillery" ]; then
	echo "[+]Error installing artillery!"
	artillery_error="TRUE"
fi

if [ ! -f "$install_path/rockyou.txt.gz" ]; then
	echo "[+]Error downloading rockyou!"
	rockyou_error="TRUE"
else
	mv rockyou.txt.gz $start_dir
	gunzip "$start_dir/rockyou.txt.gz"
	mv "$start_dir/rockyou.txt" "$start_dir/words"
	# Removing non UTF8 characters
	iconv -f utf-8 -t utf-8 -c "$start_dir/words" >> "$start_dir/words2"
	rm "$start_dir/words"
	mv "$start_dir/words2" "$start_dir/words"
fi

if [ "$respounder_error" == "TRUE" ] || [ "$artillery_error" == "TRUE" ] || [ "rockyou_error" == "TRUE"]; then
	echo "[+]Errors occured installing respounder, artillery or RockYou! Exiting!"
	exit
fi

# Get python version
echo "[+]Getting python version..."
python_version=$(python3 --version 2>&1 | cut -d ' ' -f 2)

# Verify it is a version we're expecting
if [ "$python_version" == "$recommended_python_version" ]; then
	echo "[+]Python3 version ok!"
else
	echo "[+]We detected Python3 version $python_version!"
	echo "[+]Our recommended version is $recommended_python_version, and is what this was tested on."
	echo "[+]You may choose to continue or you can exit and install the recommended version of Python3 now, and set it to the default instance."
	while true; do
		read -p "Do you want to continue? " yn
		case $yn in
			[Yy]* ) echo "[+]Continuing with script!"; break;;
			[Nn]* ) exit;;
			* ) echo "Please enter either [Y/y] or [N/n].";;
		esac
	done
fi

# Now that everything is installed as expected, we need to prompt for the path to the IP_LIST file.
echo "[+]Please enter an accessible local or network path containing the IP CSV list file."
echo "[+]The format of the CSV must be:"
echo "[+]	ip,mask,gateway,vlanid"
echo "[+]	10.0.0.2,255.255.255.0,10.0.0.1,10"
echo "[+]	etc..."
echo -n "[+]Enter the path the CSV file and press [ENTER]: "
read csv_path

# Now validate we can see the file

if [ ! -f "$csv_path" ]; then
	echo "[+]File $csv_path appears to either not exist or is not reachable."
	echo "[+]Exiting setup!"
	exit
else
	echo "[+]Executing python network interface setup."
	cd $start_dir
	python3 "$start_dir/buildIPs.py"
fi
