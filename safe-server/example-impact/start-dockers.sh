#!/bin/bash

AKKA_LOG_LEVEL=info
DOCKERHUBSTRING="rencinrig/"
RIAK_IMG=${DOCKERHUBSTRING}"riak-for-safe:latest"
#SAFE_IMG="impact-local:latest"
SAFE_IMG=${DOCKERHUBSTRING}"safe-server:1.0.1"

function pulldocker {
  IMG=$1
  IMGSTART=${IMG: 0: ${#DOCKERHUBSTRING}}
  if [ $IMGSTART = "rencinrig/" ]; then
    echo Pulling $IMG
    docker pull $IMG
  else
    echo Not pulling local $IMG
  fi
}

pulldocker $RIAK_IMG
pulldocker $SAFE_IMG

# do some cleanup
echo cleaning up previous Riak state and SAFE imports
rm -rf riak
mkdir -p riak/conf riak/data
rm -rf imports
mkdir -p imports/wp imports/dso imports/ns imports/presidio

# Riak
echo Starting Riak
docker run -d   --name=riak   --publish=8098:8098   --publish=8087:8087   --volume=$(pwd)/riak/data:/var/lib/riak   --volume=$(pwd)/riak/conf:/etc/riak  $RIAK_IMG

# WP
#echo Starting WP container
#docker run -d --name=impact-wp --publish=7777:7777 -e RIAK_IP=host.docker.internal -e SLANG_SCRIPT=impact/mvp-wp.slang -e AKKA_LOG_LEVEL=${AKKA_LOG_LEVEL} --volume=$(pwd)/imports/wp:/imports --volume=$(pwd)/principals/wp:/principalkeys $SAFE_IMG

# DP
#echo Starting DP container
#docker run -d --name=impact-dso --publish=7778:7777 -e RIAK_IP=host.docker.internal -e SLANG_SCRIPT=impact/mvp-dso.slang -e AKKA_LOG_LEVEL=${AKKA_LOG_LEVEL} --volume=$(pwd)/imports/dso:/imports --volume=$(pwd)/principals/dso:/principalkeys $SAFE_IMG

# WP/DSO (uses WP keyipair)
echo Starting WP/DSO container
docker run -d --name=impact-wpdso --publish=7777:7777 -e RIAK_IP=host.docker.internal -e SLANG_SCRIPT=impact/mvp-wp-dso.slang -e AKKA_LOG_LEVEL=${AKKA_LOG_LEVEL} --volume=$(pwd)/imports/wp:/imports --volume=$(pwd)/principals/wp:/principalkeys $SAFE_IMG

# NS
echo Starting NS container
docker run -d --name=impact-ns --publish=7779:7777 -e RIAK_IP=host.docker.internal -e SLANG_SCRIPT=impact/mvp-ns.slang -e AKKA_LOG_LEVEL=${AKKA_LOG_LEVEL} --volume=$(pwd)/imports/ns:/imports --volume=$(pwd)/principals/ns:/principalkeys $SAFE_IMG

# Presidio
echo Starting Presidio container
docker run -d --name=impact-presidio --publish=7780:7777 -e RIAK_IP=host.docker.internal -e SLANG_SCRIPT=impact/mvp-presidio.slang -e AKKA_LOG_LEVEL=${AKKA_LOG_LEVEL} --volume=$(pwd)/imports/presidio:/imports --volume=$(pwd)/principals/presidio:/principalkeys $SAFE_IMG

echo please wait, check the logs for riak, impact-wp, impact-dso, impact-ns and impact-presidio. this will take several minutes
