#!/bin/bash  

# MVP curl script

SAFE_HOST=localhost
SAFE_PORT=7779
#CURL_OPTS="-v -X POST"
CURL_OPTS="-s"

# common functions

function postRawIdSet {
	echo postRawIdSet
	curl ${CURL_OPTS} http://$SAFE_HOST:$SAFE_PORT/postRawIdSet -H "Content-Type: application/json" -d "{ \"principal\": \"$1\", \"methodParams\": [\"$1\"] }"  | jq ".result, .message"
}

function postCommonCompletionReceipt {
	echo postCommonCompletionReceipt for project $2, workflow $3
	curl ${CURL_OPTS} http://$SAFE_HOST:$SAFE_PORT/postCommonCompletionReceipt -H "Content-Type: application/json" -d "{ \"principal\": \"$1\", \"methodParams\": [\"$2\", \"$3\"] }" | jq ".result, .message"
}

function postUserCompletionReceipt {
	echo postUserCompletionReceipt for user $2, project $3, workflow $4
	curl ${CURL_OPTS} http://$SAFE_HOST:$SAFE_PORT/postUserCompletionReceipt -H "Content-Type: application/json" -d "{ \"principal\": \"$1\", \"methodParams\": [\"$2\", \"$3\", \"$4\"] }" | jq ".result, .message"
}

function postLinkReceiptForDataset {
	echo postLinkReceiptForDataset for user $2, project $3, dataset $4, workflow $5
	curl ${CURL_OPTS} http://$SAFE_HOST:$SAFE_PORT/postLinkReceiptForDataset -H "Content-Type: application/json" -d "{ \"principal\": \"$1\", \"methodParams\": [\"$2\", \"$3\", \"$4\", \"$5\"] }" | jq ".result, .message"
}

# WP portion
PRINCIPAL=ns1
PRINCIPALDIR=${PRINCIPAL%1}

USER="someUser"
PROJECT="someProject"
UUID1=6ec7211c-caaf-4e00-ad36-0cd413accc91
UUID2=1b924687-a317-4bd7-a54f-a5a0151f49d3
UUID3=26dbc728-3c8d-4433-9c4b-2e065b644db5

DP=dp1
DPDIR=${DP%1}
DPHASH=`../../scripts/hash_gen.py ../principals/${DPDIR}/${DP}.pub`
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
echo User $USER on project $PROJECT

# postRawId set for NS
postRawIdSet $PRINCIPAL

# common receipt for WF1
postCommonCompletionReceipt $PRINCIPAL $PROJECT $WF1

# user receipt for WF1
postUserCompletionReceipt $PRINCIPAL $USER $PROJECT $WF1

# common receipt for WF2
postCommonCompletionReceipt $PRINCIPAL $PROJECT $WF2

# user receipt for WF2
postUserCompletionReceipt $PRINCIPAL $USER $PROJECT $WF2

# linked receipt for dataset and WF1
postLinkReceiptForDataset $PRINCIPAL $USER $PROJECT $DATASET $WF1

# linked receipt for dataset and WF2
postLinkReceiptForDataset $PRINCIPAL $USER $PROJECT $DATASET $WF2

