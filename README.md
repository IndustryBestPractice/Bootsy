# Bootsy - History
Bootsy Collins is a legendary bass guitar player who laid down the best basslines known to man. In his honour, we are attempting to lay down some of the best baselines known to InfoSec.

# Help File
```
./bootsy.sh [-h] [-i /install/path] [-c /path/to/iplist.csv] [-w /path/to/wordlist] [-u /path/to/whitelist/file]

where (Note: All switches are optional and you will be prompted for those you don't specify):
        -h  Display this help message
        -i  Install path
        -c  IPList.csv file path
        -w  Wordlist file path (adding this option stops the download of rockyou)
	-u  Whitelist file path
```

# Bootsy - Help File Detail
A logfile of everything this script does is written to "$install_path/bootsy_install.log"

-i - By default, bootsy will install to /bootsy and have subdirs of /artillery and /respounder
-c - This is a prebuilt file that you can create ahead of time.
	> If you do not specify the location of the file via command line argument, we assume it lives in "{git_clone_dir}/ipList.csv"
	> The format of the ipList.csv file is as follows:
		ip,mask,gateway,vlanid
		10.0.0.2,255.255.255.0,10.0.0.1,10
		10.0.0.3,255.255.255.0,10.0.0.1,10
		10.105.0.2,255.255.255.0,10.105.0.1,105
		etc...
-w - This is the wordlist that is used to give the interfaces their various names. They are iterative, so make sure you have as many words in your wordlist as you do in your ipList.csv file.
	> By default, we provide you with funkList2000.txt, which is a curated list of 3,496 of Bootsy Collins' best words used in his musical library.
	> If you delete or do not want funkList2000.txt and do not provide an alternative, we will download rockyou from OffSec and use that...
-u - This is the whitelist file, for any IP's that you absolutely do not want "blacklisted" by default in artillery. You should enter items, one per line, such as your vulnerability scanner(s) (if you have one), and likely your jump box that you will use to get to this box, should you ever do an nmap of it for testing purposes and don't want yourself locked out.

# Bootsy - Notes
By combining Respounder (Responder detection) and Artillery (port and service spoofing) for deception, the hope is to quickly detect an attacker on the network early and without tipping them off that they have been found out.

This project is designed to be installed on a current version (September, 2019) of raspbian OS on the raspberry pi and has been tested on a raspberry 2 and 3. We maxed out listening on approx. 4k IP addresses on a single pi before it gave up the ghost. We recommend no more than 2,500 ips per pi.

This version has also been tested on the 32-bit version of the raspberry pixel OS in a VM; however, we did test the limit on the number of ips that could be listened on.....soooo.....have fun and experiment!

# Bootsy - General Info
During the install, this script will do the following:
	> Change the hostname of the device to bootsy### where ### is a randomly chosen number between 100 and 999
	> Setup SSH on a random port between 10,000 and 30,000
		> Prohibit root from logging in to the box via SSH
	> Setup a new, low priv user
		> Add this user to the sudoers group
		> Set this user to be allowed to login via SSH

# AFTER SETUP THE SYSTEM WILL NOT HAVE A PATH TO THE INTERNET
Because of the multi-homeing process, the routing to the internet breaks after setup. If you would like this to have access to the internet (for patching, etc), you'll have to setup the routing manually.
