FROM openjdk:8-stretch
MAINTAINER Michael J. Stealey <stealey@unc.edu>

RUN apt-get update && apt-get -y install \
  libssl-dev \
  libpam0g-dev \
  python-crypto

# Install sbt
WORKDIR /root/
ENV SBT_VERSION 1.2.8
RUN wget https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz \
  && tar -zxvf sbt-${SBT_VERSION}.tgz \
  && rm -f sbt-${SBT_VERSION}.tgz

# Download SAFE
RUN git clone https://github.com/RENCI-NRIG/SAFE.git
WORKDIR /root/SAFE

# Compile SAFE
RUN /root/sbt/bin/sbt "project safe-server" "compile"
RUN cp /root/SAFE/utility/safe_keygen.sh /root/ \
  && cp /root/SAFE/utility/hash_gen.py /root/

# create safe-apps.tar.gz
RUN cd safe-apps \
    && tar -czvf /safe-apps.tar.gz . \
    && cd -

ENV \
  SAFE_PORT=7777 \
  RIAK_IP=riak \
  SLANG_SCRIPT=strong/strong.slang \
  SLANG_CONF=strong/strong.conf.slang \
  SAFE_ROOT_PUB=strong-1.pub

COPY docker-entrypoint.sh /root/
VOLUME ["/imports", "/principalkeys"]

EXPOSE ${SAFE_PORT}

ENTRYPOINT ["/bin/bash", "/root/docker-entrypoint.sh"]
