#!/bin/bash  

# MVP curl script

SAFE_HOST=localhost
SAFE_PORT=7780
#CURL_OPTS="-v -X POST"
CURL_OPTS="-s"

# common functions
function checkAccess {
	echo Check access to dataset $2, user $3, NS $4, project $5
	curl ${CURL_OPTS} http://$SAFE_HOST:$SAFE_PORT/access -H "Content-Type: application/json" -d "{ \"principal\": \"$1\", \"methodParams\": [\"$2\", \"$3\", \"$4\", \"$5\"] }"  | jq ".result, .message"
}

# WP portion
PRINCIPAL=presidio1
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

NS=ns1
NSDIR=${NS%1}
NSHASH=`../../scripts/hash_gen.py ../principals/${NSDIR}/${NS}.pub`

echo Working on behalf of $PRINCIPAL 
echo WF1 is $WF1
echo WF2 is $WF2
echo DATASET is $DATASET
echo User $USER on project $PROJECT
echo NS is $NSHASH

# check access to dataset
checkAccess $PRINCIPAL $DATASET $USER $NSHASH $PROJECT
