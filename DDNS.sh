#!/bin/bash

ZONE_ID=$1
AUTH_MAIL=$2
AUTH_KEY=$3
DOMAIL=$4

echo $ZONE_ID $AUTH_MAIL $AUTH_KEY $DOMAIL

PRE_IP=`cat current_ip`
IP=`curl api.ipify.org/`
if [ "${PRE_IP}" == "${IP}" ]
then
    echo 'ip no change'
else
    echo 'ip is change'
   
    RES=`curl -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?type=A&name=${DOMAIL}&content=${PRE_IP}&page=1&per_page=20&order=type&direction=desc&match=all" \
     -H "X-Auth-Email: ${AUTH_MAIL}" \
     -H "X-Auth-Key: ${AUTH_KEY}" \
     -H "Content-Type: application/json"`
	
    ID=`echo ${RES} | jq '.result[0].id'`
	ID=${ID#*\"}
	ID=${ID%\"}
	echo "url:https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/$ID"
	echo 'data:' '{"type":"A","name":"'${DOMAIL}'","content":"'${IP}'","ttl":{},"proxied":true}'
	curl -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${ID}" \
    -H "X-Auth-Email: ${AUTH_MAIL}" \
    -H "X-Auth-Key: ${AUTH_KEY}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'${DOMAIL}'","content":"'${IP}'","ttl":1,"proxied":true}'
    echo ${IP} > current_ip
fi
