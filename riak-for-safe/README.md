# Riak KV

### Versions available

- 2.9.0rc6, latest: ([Dockerfile](2.9.0rc6/Dockerfile))


### What is Riak KV?

- Riak KV is a distributed NoSQL [key-value database](https://riak.com/resources/key-value-databases/index.html?p=12513.html) with advanced local and multi-cluster replication that guarantees reads and writes even in the event of hardware failures or network partitions.

### How to run

The docker definition has two optional volumes - one in which Riak stores its data and another from which Riak can read configuration files from.

1. **Riak Data** - map to `/var/lib/riak` of the container
2. **Riak Configuration** - map to `/etc/riak` of the container

The container will self populate these directories on first start, so there is no need for the user to preload data into them, they simply need to exist on the host.

Example: 

```docker
docker run -d \
  --name=riak \
  --publish=8098:8098 \
  --publish=8087:8087 \
  --volume=$(pwd)/riak/data:/data \
  --volume=$(pwd)/riak/config:/imports \
  rencinrig/riak-for-safe:latest
```

Verify that container has completed the script

```console
$ docker logs riak
!!!!
!!!! WARNING: ulimit -n is 1024; 65536 is the recommended minimum.
!!!!
pong
safesets created

WARNING: After activating safesets, nodes in this cluster
can no longer be downgraded to a version of Riak prior to 2.0
safesets has been activated

WARNING: Nodes in this cluster can no longer be
downgraded to a version of Riak prior to 2.0
safesets updated
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    24    0     0  100    24      0    110 --:--:-- --:--:-- --:--:--   110
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    24  100    24    0     0   3000      0 --:--:-- --:--:-- --:--:--  3428
Riak for SAFE test entry
2019-03-20 20:24:53.769 [info] <0.7.0> Application lager started on node 'riak@172.17.0.2'
2019-03-20 20:24:53.795 [info] <0.7.0> Application sasl started on node 'riak@172.17.0.2'
2019-03-20 20:24:53.795 [info] <0.7.0> Application asn1 started on node 'riak@172.17.0.2'
2019-03-20 20:24:53.800 [info] <0.7.0> Application crypto started on node 'riak@172.17.0.2'
...
```

Once the container completes it's startup script an HTTP endpoint will be available at port **8098**.

For example, if the container were deployed to localhost, the user could curl the test entry as such:

```console
$ curl 'http://localhost:8098/types/safesets/buckets/safe/keys/b5SCs-dUqRWMvs1GbwvwRC9Pi9yHYuSVj6oxLSU8wXs'
Riak for SAFE test entry
```

### References

GitHub releases: [https://github.com/basho/riak/releases](https://github.com/basho/riak/releases)

Precompiled build files: [https://files.tiot.jp/riak/kv/2.9/2.9.0rc5/rhel/7/](https://files.tiot.jp/riak/kv/2.9/2.9.0rc5/rhel/7/)

