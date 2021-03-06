#!/usr/bin/env bash
set -e

### populate contents of /imports if external volume mount is used
_safe_apps_tgz() {
  cp /safe-apps.tar.gz /imports/safe-apps.tar.gz
  cd /imports
  echo "!!! populating /imports with initial contents !!!"
  tar -zxvf safe-apps.tar.gz
  cd -
  rm -f /imports/safe-apps.tar.gz
}

### main ###

# external volume mounts will be empty on initial run
if [[ ! -d /imports/strong ]]; then
  _safe_apps_tgz
fi

# Run SAFE server
cd ~/SAFE

# Set up: configuration the storage server for SAFE
sed -i "/.*url = \"http/ s:.*:    url = \"http\://${RIAK_IP}\:8098/types/safesets/buckets/safe/keys\":" \
  safe-server/src/main/resources/application.conf

# turn on server log
# sed -i "/.*<root level=\"error/ s:.*:    <root level=\"info\">:" safe-server/src/main/resources/logback.xml

safe_root=`python /root/hash_gen.py /principalkeys/${SAFE_ROOT_PUB}`

sed -i "/.*defenv RootDir()/ s:.*:defenv RootDir() \:- \"${safe_root}\:root\"\.:" /imports/${SLANG_CONF}

# Run the strong server
~/sbt/bin/sbt "project safe-server" "run -f /imports/${SLANG_SCRIPT} -r safeService  -kd  /principalkeys"
# Start the CLI
#~/sbt/bin/sbt "project safe-lang" "run"

exec "${@}"
tail -f /dev/null
