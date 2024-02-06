#!/bin/bash
#Credits go to http://www.administrator.de/contentid/214598 "Informationen aus dem Webinterface einer Fritz!Box via Shellscript auslesen"
#Script below was tested on Fritz!box 7360 with OS 6.30
_BOXURL="http://fritz.box"
_USERNAME=""
_PASSWORD="YOURPASSWORDHERE"
_CHALLENGE=$(curl -s ${_BOXURL}/login.lua | grep "^g_challenge" | awk -F '"' '{ print $2 }')
_MD5=$(echo -n ${_CHALLENGE}"-"${_PASSWORD} | iconv -f ISO8859-1 -t UTF-16LE | md5sum -b | awk '{print substr($0,1,32)}')
_RESPONSE="${_CHALLENGE}-${_MD5}"
_SID=$(curl -i -s -k -d 'response='${_RESPONSE} -d 'page=' -d "username=${_USERNAME}" "${_BOXURL}/login.lua" | grep "Location:" | grep -Poi 'sid=[a-f\d]+' | cut -d '=' -f2)

#DSL-Informationen zur Leitungsqualität
_PAGE_DSL_STATS=$(curl -s ${_BOXURL}/internet/dsl_stats_tab.lua -d 'sid='${_SID})
_DSLAM_DOWN=$(echo "${_PAGE_DSL_STATS}" | awk 'match($0,/Max. DSLAM throughput.*"c3">([0-9]+)<\/td>.*Min. DSLAM throughput/,arr){print arr[1]};')
_DSLAM_UP=$(echo "${_PAGE_DSL_STATS}" | awk 'match($0,/Max. DSLAM throughput.*"c4">([0-9]+)<\/td>.*Min. DSLAM throughput/,arr){print arr[1]};')

_ATTAINABLE_DOWN=$(echo "${_PAGE_DSL_STATS}" | awk 'match($0,/Attainable throughput.*"c3">([0-9]+)<\/td>.*Current throughput/,arr){print arr[1]};')
_ATTAINABLE_UP=$(echo "${_PAGE_DSL_STATS}" | awk 'match($0,/Attainable throughput.*"c4">([0-9]+)<\/td>.*Current throughput/,arr){print arr[1]};')

_CURRENT_DOWN=$(echo "${_PAGE_DSL_STATS}" | awk 'match($0,/Current throughput.*"c3">([0-9]+)<\/td>.*Seamless rate adaptation/,arr){print arr[1]};')
_CURRENT_UP=$(echo "${_PAGE_DSL_STATS}" | awk 'match($0,/Current throughput.*"c4">([0-9]+)<\/td>.*Seamless rate adaptation/,arr){print arr[1]};')

#Convert kbit to Mbit with .1 decimal point
dslam_down_mbit=$(echo "scale=1; $_DSLAM_DOWN/1000" | bc)
dslam_up_mbit=$(echo "scale=1; $_DSLAM_UP/1000" | bc)
att_down_mbit=$(echo "scale=1; $_ATTAINABLE_DOWN/1000" | bc)
att_up_mbit=$(echo "scale=1; $_ATTAINABLE_UP/1000" | bc)
current_down_mbit=$(echo "scale=1; $_CURRENT_DOWN/1000" | bc)
current_up_mbit=$(echo "scale=1; $_CURRENT_UP/1000" | bc)

echo "Max. DSLAM throughput - Down:     $_DSLAM_DOWN kbit/s ("$dslam_down_mbit" Mbit) "
echo "Max. DSLAM throughput - Up:       $_DSLAM_UP kbit/s ("$dslam_up_mbit" Mbit) "
echo ""
echo "Attainable throughput - Down:     $_ATTAINABLE_DOWN kbit/s ("$att_down_mbit" Mbit) "
echo "Attainable throughput - Up:       $_ATTAINABLE_UP kbit/s ("$att_up_mbit" Mbit) "
echo ""
echo "Current throughput - Download:    $_CURRENT_DOWN kbit/s ("$current_down_mbit" Mbit) "
echo "Current throughput - Upload:      $_CURRENT_UP kbit/s ("$current_up_mbit" Mbit) "
