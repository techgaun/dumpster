#!/bin/bash

ZWAY_SESSION="54c3acfc-0ac7-0705-468b-3454da165067"

for (( i = 0; i < 1000; i++)); do
  sleep 3
	curl 'http://192.168.168.111:8083/ZAutomation/api/v1/devices/ZWayVDev_zway_2-0-38/command/off' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/57.0.2987.98 Chrome/57.0.2987.98 Safari/537.36' -H 'Accept: application/json, text/plain, */*' -H 'Referer: http://192.168.168.111:8083/smarthome/' -H "Cookie: ZWAYSession=54c3acfc-0ac7-0705-468b-3454da165067" -H 'Connection: keep-alive' -H "ZWAYSession: ${ZWAY_SESSION}" --compressed

  echo -e "\nturned off the light"
	sleep 3

  echo -e "\nturned on the light"
	curl 'http://192.168.168.111:8083/ZAutomation/api/v1/devices/ZWayVDev_zway_2-0-38/command/exact?level=99' -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/57.0.2987.98 Chrome/57.0.2987.98 Safari/537.36' -H 'Accept: application/json, text/plain, */*' -H 'Referer: http://192.168.168.111:8083/smarthome/' -H 'Cookie: ZWAYSession=54c3acfc-0ac7-0705-468b-3454da165067' -H 'Connection: keep-alive' -H "ZWAYSession: ${ZWAY_SESSION}" --compressed
done
