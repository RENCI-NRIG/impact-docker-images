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

PRINCIPAL=dso1

. ./common-info.sh

# postRawId set for DSO
postRawIdSet $PRINCIPAL

# publish two-flow policy
postTwoFlowDataOwnerPolicy $PRINCIPAL $DATASET $WF1 $WF2

