#!/usr/bin/python

import subprocess
import sys
import csv
import re
import os

def main(argv):
    # if we pass an argument for the CWD, use that instead of the REAL pwd
    # if len(sys.argv) > 1:
    #    cwd = sys.argv[1]
    # else:
    #    cwd = (os.getcwd())
    cwd = (os.getcwd())
    print("Current working directory is: " + str(cwd))
    ipFile = cwd + "/ipList.csv"
    outDir = cwd + "/ips/"
    #outDir = "/etc/network/interfaces.d/"
    wList = cwd + "/words"

    # Read command line arguments
    if sys.argv[1:]:
        # This is the ipFile
        ipFile = sys.argv[1].strip()
    if sys.argv[2:]:
        # This is the wList
        wList = sys.argv[2].strip()
    if sys.argv[3:]:
        # This is the outDir
        outDir = sys.argv[3].strip()


    # Check if files exist
    if not os.path.exists(ipFile):
        print("[+]IP file: " + ipFile + " does not exist.")
        sys.exit(0)
    else:
        print("[+]Found ipFile at location: " + str(ipFile) + ".")

    if not os.path.exists(outDir):
        print("[+]Output directory: " + outDir + " does not exist - creating it!")
        try:
            os.mkdir(outDir)
            print("[+]Created directory successfully!")
        except:
            print("[+]Error creating directory, exiting!")
            sys.exit(0)
    else:
        print("[+]Found output directory: " + outDir + ".")

    if not os.path.exists(wList):
        print("[+]Word list: " + wList + " does not exist.")
        sys.exit(0)
    else:
        print("[+]Found wordlist: " + wList + ".")


    # read word list in for interfaces missing vlanid
    with open(wList) as f:
         lineList = f.readlines() 

    lineCounter = 0

    # loop through CSV file and build interface files
    with open(ipFile) as csv_file:
        reader = csv.DictReader(csv_file, delimiter=',')
        for row in reader:
                 #######
                 # Build vlan ID info
                 
                 if row['vlanid']:
                     vlanid = row['vlanid']
                 else:
                     vlanid = re.sub('[^a-zA-Z0-9\n\.]', '',lineList[lineCounter]).rstrip('\n')
                     lineCounter += 1
                 print("[+]Creating vlan " + str(vlanid))
                 
                 outfile = outDir + "eth0-" + vlanid
                 outfile = outfile.strip(' ')
                 outf = open(outfile, 'w')

                 settings = "auto eth0:" + vlanid + "\r\n"
                 settings += "iface eth0:" + vlanid + " inet static\r\n"
                 settings += "address " + row['ip'] + "\r\n"
                 settings += "netmask " + row['mask'] + "\r\n"
                 settings += "gateway " + row['gateway'] + "\r\n"
                 
                 print("[+]Writing settings to file: ")
                 print(str(settings))
                 print("[+]Writing to file " + str(outf))
                 outf.write(settings)
                 outf.close()

if __name__ == "__main__":
    main(sys.argv[1:])
