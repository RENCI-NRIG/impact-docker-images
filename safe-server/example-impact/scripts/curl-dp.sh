#!/bin/bash  

# MVP curl script

SAFE_HOST=localhost
SAFE_PORT=7778
#CURL_OPTS="-v -X POST"
CURL_OPTS="-s"

# common functions

function postRawIdSet {
	echo postRawIdSet
	curl ${CURL_OPTS} http://$SAFE_HOST:$SAFE_PORT/postRawIdSet -H "Content-Type: application/json" -d "{ \"principal\": \"$1\", \"methodParams\": [\"$1\"] }"  | jq ".result, .message"
}

function postTwoFlowDataOwnerPolicy {
	echo postTwoFlowDataOwnerPolicy for dataset $2, wf1 $3, wf2 $4
	curl ${CURL_OPTS} http://$SAFE_HOST:$SAFE_PORT/postTwoFlowDataOwnerPolicy -H "Content-Type: application/json" -d "{ \"principal\": \"$1\", \"methodParams\": [\"$2\", \"$3\", \"$4\"] }" | jq ".result, .message"
}

# WP portion
PRINCIPAL=dp1
PRINCIPALDIR=${PRINCIPAL%1}
UUID1=6ec7211c-caaf-4e00-ad36-0cd413accc91
UUID2=1b924687-a317-4bd7-a54f-a5a0151f49d3
UUID3=26dbc728-3c8d-4433-9c4b-2e065b644db5

DPHASH=`../../scripts/hash_gen.py ../principals/${PRINCIPALDIR}/${PRINCIPAL}.pub`
DATASET=$DPHASH:$UUID3

WP=wp1
WPDIR=${WP%1}
WPHASH=`../../scripts/hash_gen.py ../principals/${WPDIR}/${WP}.pub`
WF1=$WPHASH:$UUID1
WF2=$WPHASH:$UUID2

echo Working on behalf of $PRINCIPAL 
echo WF1 is $WF1
echo WF2 is $WF2
echo DATASET is $DATASET

# postRawId set for DP
postRawIdSet $PRINCIPAL

# publish two-flow policy
postTwoFlowDataOwnerPolicy $PRINCIPAL $DATASET $WF1 $WF2

