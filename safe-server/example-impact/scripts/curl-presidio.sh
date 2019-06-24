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

. ./common-info.sh

# check access to dataset
checkAccess $PRINCIPAL $DATASET $USER $NSHASH $PROJECT
