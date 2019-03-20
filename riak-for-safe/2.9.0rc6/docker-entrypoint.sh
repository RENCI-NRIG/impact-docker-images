#!/usr/bin/env bash
set -e

### populate contents of /var/lib/riak if external volume mount is used
_var_lib_riak_tgz() {
  cp /var_lib_riak.tar.gz /var/lib/riak/var_lib_riak.tar.gz
  cd /var/lib/riak/
  echo "!!! populating /var/lib/riak with initial contents !!!"
  tar -zxvf var_lib_riak.tar.gz
  cd /
  rm -f /var/lib/riak/var_lib_riak.tar.gz
}

### populate contents of /etc/riak if external volume mount is used
_etc_riak() {
  cp /etc_riak.tar.gz /etc/riak/etc_riak.tar.gz
  cd /etc/riak
  echo "!!! populating /etc/riak with initial contents !!!"
  tar -zxvf etc_riak.tar.gz
  cd /
  rm -f /etc/riak/etc_riak.tar.gz
}

### main ###

# external volume mounts will be empty on initial run
if [[ ! -d /var/lib/riak/ring ]]; then
  _var_lib_riak_tgz
fi
if [[ ! -f /etc/riak/riak.conf ]]; then
  _etc_riak
fi

# set ulimit
ulimit -n 65536

# update riak.conf
internal_ip=$(hostname -i)
sed -i "/^listener.http.internal/ s:.*:listener.http.internal = ${internal_ip}\:8098:" /etc/riak/riak.conf
sed -i "/^listener.protobuf.internal/ s:.*:listener.protobuf.internal = ${internal_ip}\:8087:" /etc/riak/riak.conf
sed -i "/^nodename = / s:.*:nodename = riak@${internal_ip}:" /etc/riak/riak.conf

# Initialize Riak with a SAFE bucket if it does not already exist
riak start
riak ping
if [[ "$(riak-admin bucket-type status safesets | grep active: | rev | cut -d ' ' -f1 | rev)" == 'true' ]]; then
  echo "bucket-type safesets already created"
else
  riak-admin bucket-type create safesets '{"props":{"n_val":1, "w":1, "r":1, "pw":1, "pr":1}}'
fi

riak-admin bucket-type activate safesets
riak-admin bucket-type update safesets '{"props":{"allow_mult":false}}'

# test config internally
sleep 10

# put a test entry into Riak
curl -XPUT  \
  'http://'${internal_ip}':'${RIAK_HTTP}'/types/safesets/buckets/safe/keys/b5SCs-dUqRWMvs1GbwvwRC9Pi9yHYuSVj6oxLSU8wXs' \
  -H 'Content-Type: text/plain'   \
  -d 'Riak for SAFE test entry'

# get test entry from Riak
curl 'http://'${internal_ip}':'${RIAK_HTTP}'/types/safesets/buckets/safe/keys/b5SCs-dUqRWMvs1GbwvwRC9Pi9yHYuSVj6oxLSU8wXs'

# Trap SIGTERM and SIGINT and tail the log file indefinitely
tail -n 1024 -f /var/log/riak/console.log &
PID=$!
trap "riak stop; kill $PID" SIGTERM SIGINT
wait $PID
