#!/bin/bash
# Script : NetworkInfo by CaptainIgloo - may 29 2016
# mac=$(/sbin/ifconfig eth0 | sed -e's/^.*HWaddr \([^ ]*\) .*$/\1/;t;d')
# Function check port
function checkport {
	if nc -zv -w30 $1 $2 <<< '' &> /dev/null
	then
		echo "[+] Outbound socket $1:$2 is open"
	else
		echo "[-] Outbound socket $1:$2 is closed"
	fi
}
# Function search key json
function jsonValue() {
	key=$1 # Key search
	num=$2 # Index array
	awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$key'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}

# start run
echo --- Networking report ---
echo "Localhost : "$(hostname)
# Get default gateway of network adapter
gateway=$(/sbin/ip route | awk '/default/ { print $3 }')
echo "Network gateway : " $gateway
# Find MAC address of gateway (router)
macrouter=$(nmap -sP $gateway | awk '/MAC Address:/{print $3;}')
echo "MAC router : " $macrouter
# -- Get Standard OUI MAC Vendor
# json_macvendor=`curl -s -X GET http://www.macvendorlookup.com/api/v2/$macrouter` # Other service
json_macvendor=`curl -s -X GET https://macvendors.co/api/$macrouter`
#echo "DEBUG : "$json_macvendor
macvendor=`echo $json_macvendor | jsonValue "company" 1`
echo "MAC Vendor : "$macvendor
# -- Get public IP without onlline services
ippublic=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo "Public IP : " $ippublic
# -- Get IP informations
json_ip_api=`curl -s -X GET "http://ip-api.com/json/?fields=country,countryCode,city,zip,isp,org,as,reverse,mobile,proxy,timezone,regionName,lat,lon"`
#echo "DEBUG : "$json_ip_api
isp=`echo $json_ip_api | jsonValue "isp" 1`
reverse=`echo $json_ip_api | jsonValue "reverse" 1`
mobile=`echo $json_ip_api | jsonValue "mobile" 1`
timezone=`echo $json_ip_api | jsonValue "timezone" 1`
city=`echo $json_ip_api | jsonValue "city" 1`
latitude=`echo $json_ip_api | jsonValue "lat" 1`
longitude=`echo $json_ip_api | jsonValue "lon" 1`
regionName=`echo $json_ip_api | jsonValue "regionName" 1`
zip=`echo $json_ip_api | jsonValue "zip" 1`
country=`echo $json_ip_api | jsonValue "country" 1`
echo "Internet service provider : "$isp
echo "Reverse DNS : "$reverse
echo "Mobile access : "$mobile
echo "Country : "$country
echo "City : "$city
echo "Zipcode : "$zip
echo "Region : "$regionName
echo "Timezone : "$timezone
echo "Latitude : "$latitude
echo "Longitude : "$longitude
echo -----------------
# Sample check
checkport 'portquiz.net' 22
checkport 'portquiz.net' 80
checkport 'portquiz.net' 443
checkport 'portquiz.net' 22
