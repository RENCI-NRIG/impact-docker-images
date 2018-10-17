The docker definition has two volumes - one in which Neo4j stores its data and another, from which APOC can import external file (e.g. GraphML) into Neo4j. Both must be specified when starting up the container.

To run this docker

```
$ docker pull rencinrig/neo4j-apoc:<tag>
$ docker run --publish=7474:7474 --publish=7687:7687 --volume=</path/to/neo4j/data/directory>:/data --volume=</path/to/where/you/want/to/import/graphs/using/apoc/from>:/imports neo4j-apoc:<tag>
```

