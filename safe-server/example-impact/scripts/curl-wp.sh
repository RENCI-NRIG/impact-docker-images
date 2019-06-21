#!/bin/bash 

# MVP curl script

SAFE_HOST=localhost
SAFE_PORT=7777
#CURL_OPTS="-v -X POST"
CURL_OPTS="-s"

# common functions

function postRawIdSet {
	echo postRawIdSet
	curl ${CURL_OPTS} http://$SAFE_HOST:$SAFE_PORT/postRawIdSet -H "Content-Type: application/json" -d "{ \"principal\": \"$1\", \"methodParams\": [\"$1\"] }"  | jq ".result, .message"
}

function postPerFlowRule {
	echo postPerFlowRule
	curl ${CURL_OPTS} http://$SAFE_HOST:$SAFE_PORT/postPerFlowRule -H "Content-Type: application/json" -d "{ \"principal\": \"$1\", \"methodParams\": [\"$2\"] }" | jq ".result, .message"
}

# WP portion
PRINCIPAL=wp1
UUID1=6ec7211c-caaf-4e00-ad36-0cd413accc91
UUID2=1b924687-a317-4bd7-a54f-a5a0151f49d3

PRINCIPALDIR=${PRINCIPAL%1}
WPHASH=`../../scripts/hash_gen.py ../principals/${PRINCIPALDIR}/${PRINCIPAL}.pub`
WF1=$WPHASH:$UUID1
WF2=$WPHASH:$UUID2

echo Working on behalf of $PRINCIPAL 
echo WF1 is $WF1
echo WF2 is $WF2

# postRawId set for WP
postRawIdSet $PRINCIPAL

# publish RA WF
postPerFlowRule $PRINCIPAL $WF1

# publish IA WF
postPerFlowRule $PRINCIPAL $WF2
