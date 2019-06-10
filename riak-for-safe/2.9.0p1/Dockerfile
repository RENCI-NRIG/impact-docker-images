FROM ubuntu:bionic
MAINTAINER Michael J. Stealey <stealey@unc.edu>

ARG RIAK_VERSION=2.9.0p1

# install riak
RUN apt-get update && apt-get -y install \
  wget \
  curl \
  && wget https://files.tiot.jp/riak/kv/2.9/${RIAK_VERSION}/ubuntu/bionic64/riak_${RIAK_VERSION}-1_amd64.deb \
  && dpkg -i /riak_${RIAK_VERSION}-1_amd64.deb || true \
  && apt-get -y install -f \
  && rm -f /riak_${RIAK_VERSION}-1_amd64.deb \
  && apt-get clean

# environment variable defaults
# port list taken from https://docs.riak.com/dataplatform/1.0.0/configuring/default-ports/
ENV \
  RIAK_SSH=22 \
  RIAK_EPMD_LISTENER=4369 \
  RIAK_LEADER_ELECTION=5323 \
  RIAK_INTER_NODE_COMMUNICATION=6000-7999 \
  RIAK_REDIS=6379 \
  RIAK_CACHE_PROXY=22122 \
  RIAK_CACHE_PROXY_STATS=22123 \
  RIAK_SPARK_MASTER=7077 \
  RIAK_SPARK_MASTER_WEB_UI=8080 \
  RIAK_SPARK_WORKER=7078 \
  RIAK_SPARK_WORKER_WEB_UI=8081 \
  RIAK_PROTOCOL_BUFFER=8087 \
  RIAK_HTTP=8098 \
  RIAK_HANDOF=8099 \
  RIAK_SEARCH_SOLR=8093 \
  RIAK_SEARCH_SOLR_JMX=8985 \
  RIAK_CLUSTER_MANAGER=9080 \
  RIAK_EE_JMX=41110


# create var_lib_riak.tar.gz
RUN cd /var/lib/riak \
    && tar -czvf /var_lib_riak.tar.gz . \
    && cd /

# create etc_riak.tar.gz
RUN cd /etc/riak \
    && tar -czvf /etc_riak.tar.gz . \
    && cd /

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
VOLUME /var/lib/riak /etc/riak

EXPOSE ${RIAK_PROTOCOL_BUFFER} ${RIAK_HTTP}

ENTRYPOINT ["/docker-entrypoint.sh"]
