# ETCD - Checking and removing old/unhealthy nodes

The intention of this project is to check and remove old and unhealthy nodes on ETCD cluster.

This project is an evaluation for ETCD auto-health cluster.

## How to use

By default, it will start etcd cluster.

### Checking the ETCD version or getting etcd command help

```bash
docker run --rm -it etcd_with_unhealth_check --version
docker run --rm -it etcd_with_unhealth_check --help
```

### Running the ETCD

By default, you can set up three variable. They're `MY_CLUSTER_TOKEN`, `MY_DISCOVERY_TOKEN` and `MY_IP`. The most important to bootstrap the cluster is `MY_DISCOVERY_TOKEN`, basically it will generate an URL to other nodes can communicate and find each other.

```bash
docker run --rm -d -e 'MY_DISCOVERY_TOKEN=https://discovery.etcd.io/<YOUR_DISCOVERY_TOKE>' etcd_with_unhealth_check
```

> If you don't pass the var `MY_DISCOVERY_TOKEN`, each node will be a single node/cluster.
