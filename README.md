# Bootsy
Bootsy Collins is a legendary bass guitar player who laid down the best basslines known to man. In his honour, we are attempting to lay down some of the best baselines known to InfoSec.

By combining Respounder (Responder detection) and Artillery (port and service spoofing) for deception, the hope is to quickly detect an attacker on the network early and without tipping them off that they have been found out.

# Usage
```
./bootsy.sh [-h] [-i /install/path] [-c /path/to/iplist.csv] [-w /path/to/wordlist] [-u /path/to/whitelist/file]

where (Note: All switches are optional and you will be prompted for those you don't specify):
        -h  Display this help message
        -i  Install path
        -c  IPList.csv file path
        -w  Wordlist file path (adding this option stops the download of rockyou)
	-u  Whitelist file path
```
