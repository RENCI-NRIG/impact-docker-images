# impact-docker-images

Docker images for ImPACT project


## neo4j/APOC

Versions available:

- 3.5.0, latest: ([Dockerfile](neo4j/3.5.0/Dockerfile))
- 3.4.7: ([Dockerfile](neo4j/3.4.7/Dockerfile))

What is Neo4j?

- Neo4j is an open-source, NoSQL, native graph database that provides an ACID-compliant transactional backend for your applications. Initial development began in 2003, but it has been publicly available since 2007. The source code, written in Java and Scala, is available for free on GitHub or as a user-friendly desktop application download. Neo4j has both a Community Edition and Enterprise Edition of the database. The Enterprise Edition includes all that Community Edition has to offer, plus extra enterprise requirements such as backups, clustering, and failover abilities.
- Official Docker image: [https://hub.docker.com/_/neo4j/](https://hub.docker.com/_/neo4j/)
- GitHub repository: [https://github.com/neo4j/docker-neo4j-publish](https://github.com/neo4j/docker-neo4j-publish)

What is APOC?

- APOC stands for Awesome Procedures on Cypher. Before APOC’s release, developers needed to write their own procedures and functions for common functionality that Cypher or the Neo4j database had not yet implemented for support. Each developer might write his own version of these functions, causing a lot of duplication.


How to run:

```
docker run -d \
  --user=$(id -u):$(id -g) \
  --name=neo4j \
  --publish=7473:7473 \
  --publish=7474:7474 \
  --publish=7687:7687 \
  --volume=${NEO4J_HOST_PATH:-$(pwd)/neo4j/data}:/data \
  --volume=${NEO4J_HOST_PATH:-$(pwd)/neo4j/logs}:/logs \
  --volume=${NEO4J_HOST_PATH:-$(pwd)/neo4j}:${NEO4J_DOCKER_PATH:-/imports/} \
  -e NEO4J_AUTH=${NEO4J_USER:-neo4j}/${NEO4J_PASS:-password} \
  rencinrig/neo4j-apoc:latest
```
