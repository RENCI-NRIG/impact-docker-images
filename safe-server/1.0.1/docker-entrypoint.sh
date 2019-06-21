#!/usr/bin/env bash
set -e

### populate contents of /imports if external volume mount is used
_safe_apps_tgz() {
  cp /$IMPACT_APP /imports/$IMPACT_APP
  cd /imports
  echo "!!! populating /imports with initial contents !!!"
  tar -zxvf $IMPACT_APP
  cd -
  rm -f /imports/$IMPACT_APP
}

### main ###

# external volume mounts will be empty on initial run
if [[ ! -d /imports/impact ]]; then
  _safe_apps_tgz
fi

# Run SAFE server
cd ~/SAFE

# Set akka logging level ("info", "debug", etc)
sed -i "/.*<root level=\"error/ s:.*:    <root level=\"${AKKA_LOG_LEVEL}\">:" safe-server/src/main/resources/logback.xml

# Set up: configuration the storage server for SAFE
sed -i "/.*url = \"http/ s:.*:    url = \"http\://${RIAK_IP}\:8098/types/safesets/buckets/safe/keys\":" \
  safe-server/src/main/resources/application.conf

# Run the strong server
~/sbt/bin/sbt "project safe-server" "run -f /imports/${SLANG_SCRIPT} -r safeService  -kd  /principalkeys"
# Start the CLI
#~/sbt/bin/sbt "project safe-lang" "run"

exec "${@}"
tail -f /dev/null
