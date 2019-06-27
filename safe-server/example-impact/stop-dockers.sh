#!/bin/bash

echo This script will stop and remove all running dockers

echo Riak
docker stop riak > /dev/null >& /dev/null
docker rm riak > /dev/null >& /dev/null
echo "SAFE WP (if present)"
docker stop impact-wp > /dev/null >& /dev/null
docker rm impact-wpi > /dev/null >& /dev/null
echo "SAFE DSO (if present)"
docker stop impact-dso > /dev/null >& /dev/null
docker rm impact-dso > /dev/null >& /dev/null
echo "SAFE WP/DSO (if present)"
docker stop impact-wpdso > /dev/null >& /dev/null
docker rm impact-wpdso > /dev/null >& /dev/null
echo "SAFE NS"
docker stop impact-ns > /dev/null >& /dev/null
docker rm impact-ns > /dev/null >& /dev/null
echo "SAVE Presidio"
docker stop impact-presidio > /dev/null >& /dev/null
docker rm impact-presidio > /dev/null >& /dev/null
