#!/bin/bash

AKKA_LOG_LEVEL=info

# Riak
echo cleaning up previous Riak state
rm -rf riak
mkdir -p riak/conf riak/data
echo Starting Riak
docker run -d   --name=riak   --publish=8098:8098   --publish=8087:8087   --volume=$(pwd)/riak/data:/var/lib/riak   --volume=$(pwd)/riak/conf:/etc/riak   rencinrig/riak-for-safe:latest

# WP
echo Starting WP container
docker run -d --name=impact-wp --publish=7777:7777 -e RIAK_IP=host.docker.internal -e SLANG_SCRIPT=impact/mvp-wp.slang -e AKKA_LOG_LEVEL=${AKKA_LOG_LEVEL} --volume=$(pwd)/imports/wp:/imports --volume=$(pwd)/principals/wp:/principalkeys safe-impact:latest

# DP
echo Starting DP container
docker run -d --name=impact-dp --publish=7778:7777 -e RIAK_IP=host.docker.internal -e SLANG_SCRIPT=impact/mvp-dso.slang -e AKKA_LOG_LEVEL=${AKKA_LOG_LEVEL} --volume=$(pwd)/imports/dp:/imports --volume=$(pwd)/principals/dp:/principalkeys safe-impact:latest

# NS
echo Starting NS container
docker run -d --name=impact-ns --publish=7779:7777 -e RIAK_IP=host.docker.internal -e SLANG_SCRIPT=impact/mvp-ns.slang -e AKKA_LOG_LEVEL=${AKKA_LOG_LEVEL} --volume=$(pwd)/imports/ns:/imports --volume=$(pwd)/principals/ns:/principalkeys safe-impact:latest

# Presidio
echo Starting Presidio container
docker run -d --name=impact-presidio --publish=7780:7777 -e RIAK_IP=host.docker.internal -e SLANG_SCRIPT=impact/mvp-presidio.slang -e AKKA_LOG_LEVEL=${AKKA_LOG_LEVEL} --volume=$(pwd)/imports/presidio:/imports --volume=$(pwd)/principals/presidio:/principalkeys safe-impact:latest

echo please wait, check the logs for riak, impact-wp, impact-dp, impact-ns and impact-presidio. this will take several minutes
