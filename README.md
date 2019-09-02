# Bootsy
Bootsy Collins is a legendary bass guitar player who laid down the best basslines known to man. In his honour, we are attempting to lay down some of the best baselines known to InfoSec.

By combining Respounder (Responder detection) and Artillery (port and service spoofing) for deception, the hope is to quickly detect an attacker on the network early and without tipping them off that they have been found out.

# Usage
./bootsy.sh [-h] [-i /install/path] [-s] [-c /path/to/iplist.csv] [-w /path/to/wordlist] [-l /path/to/syslog/config]

where (Note: All switches are optional and you will be prompted for those you don't specify):
        -h  Display this help message
        -i  Install path
        -s  Silent switch. Don't prompt for validation of versions and other stuff. See our github for example files.
                Silent switch expects the following to exist:
                        $start_dir/ipList.csv
                        $start_dir/syslog_config
                Silent switch does the following:
                        > Checks if funkList2000.txt exists and if not, checks for
                          user input file, and if not exists then downloads rockyou for the wordlist
                        > Creates folder $start_dir if it doesn't already exist
                        > Does not prompt for email\syslog config at all
        -c  IPList.csv file path
        -w  Wordlist file path (adding this option stops the download of rockyou)
        -l  Syslog config file path (leave this option blank to load our default config)
        -u  Runs just the security portion of the script
