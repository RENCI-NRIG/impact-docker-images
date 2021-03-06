# Dockerfile for Neo4j with APOC plugin
FROM neo4j:3.5.0
MAINTAINER Ilya Baldin <ibaldin@renci.org>
LABEL maintainer="ibaldin@renci.org"

# versions
ARG NEO4J_VERSION=3.5.0
ENV APOC_VERSION=3.5.0.1

# Fetch the APOC plugin
RUN wget --directory-prefix=/var/lib/neo4j/plugins \
  https://github.com/neo4j-contrib/neo4j-apoc-procedures/\
releases/download/${APOC_VERSION}/apoc-${APOC_VERSION}-all.jar

# mangle Neo4j config to allow APOC to function
RUN printf "# enable APOC\ndbms.security.procedures.unrestricted=apoc.*\napoc.import.file.enabled=true\n" >> /var/lib/neo4j/conf/neo4j.conf

# Create a graph import directory
RUN mkdir /imports \
  && chmod -R 777 /imports

VOLUME /imports
EXPOSE 7474 7473 7687

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["neo4j"]
