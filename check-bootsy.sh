#!/bin/bash

#respounder
rresults=$(journalctl -o cat -q --no-pager -t responder-detected --since="-1m")
rlinecount=$(echo "$rresults" | grep responder | wc -l)

#artillery
aresults=$(journalctl -o cat -q --no-pager -u artillery --since="-1m" | grep address)
alinecount=$(echo "$aresults" | grep address | wc -l)

if [ $rlinecount -gt 0 ]; then
  logger -t respounder "bootsy-alert $rresults"
fi

if [ $alinecount -gt 0 ]; then
  aformat=$echo $aresults | uniq | awk -v alines="$alinecount" '{print $12 " attempted to connect to port " $20 " " alines " time(s)"}')
  logger -t artillery "bootsy-alert $aformat"
fi
