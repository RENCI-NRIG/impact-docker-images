#!/bin/bash

docker stop riak
docker rm riak
docker stop impact-wp
docker rm impact-wp
docker stop impact-dso
docker rm impact-dso
docker stop impact-ns
docker rm impact-ns
docker stop impact-presidio
docker rm impact-presidio
