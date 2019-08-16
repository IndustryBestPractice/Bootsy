#!/usr/bin/python

import subprocess
import sys
import csv
import re
import os

cwd = (os.getcwd())

ipFile = cwd + "/ipList.csv"
outDir = cwd + "/ips/"
#outDir = "/etc/network/interfaces.d/"
wList = cwd + "/words"

# Read command line arguments
if sys.argv[1:]:
    ipFile = sys.argv[1].strip()
    if sys.argv[2:]:
         wList = sys.argv[2].strip()
         if sys.argv[3:]:
              outDir = sys.argv[3].strip()


# Check if files exist
if not os.path.exists(ipFile):
    print("IP file: " + ipFile + " does not exist.")
    sys.exit(0)

if not os.path.exists(outDir):
    print("Output directory: " + outDir + " does not exist.")
    sys.exit(0)

if not os.path.exists(wList):
    print("Word list: " + wList + " does not exist.")
    sys.exit(0)


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
             
             outfile = outDir + "eth0-" + vlanid
             outfile = outfile.strip(' ')
             outf = open(outfile, 'w')

             settings = "auto eth0:" + vlanid + "\r\n"
             settings += "iface eth0:" + vlanid + " inet static\r\n"
             settings += "address " + row['ip'] + "\r\n"
             settings += "netmask " + row['mask'] + "\r\n"
             settings += "gateway " + row['gateway'] + "\r\n"
             
             outf.write(settings)
             outf.close()
