# Dockerfile for Neo4j with APOC plugin

ARG N4J_VERSION=3.4.7
FROM neo4j:$N4J_VERSION

LABEL maintainer="ibaldin@renci.org"
ENV APOC_VERSION=3.4.0.2

# Fetch the APOC plugin
ADD https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/${APOC_VERSION}/apoc-${APOC_VERSION}-all.jar /var/lib/neo4j/plugins

# mangle Neo4j config to allow APOC to function
RUN printf "# enable APOC\ndbms.security.procedures.unrestricted=apoc.*\napoc.import.file.enabled=true\n" >> /var/lib/neo4j/conf/neo4j.conf 

# Create a graph import directory
RUN mkdir /imports && chmod -R 777 /imports

VOLUME /imports

EXPOSE 7474 7473 7687

ENTRYPOINT ["/sbin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["neo4j"]

