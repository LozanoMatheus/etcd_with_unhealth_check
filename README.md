[![](https://images.microbadger.com/badges/image/lozanomatheus/etcd_with_unhealthy_check:latest.svg)](https://microbadger.com/images/lozanomatheus/etcd_with_unhealthy_check:latest) [![](https://images.microbadger.com/badges/version/lozanomatheus/etcd_with_unhealthy_check:latest.svg)](https://microbadger.com/images/lozanomatheus/etcd_with_unhealthy_check:latest)

# ETCD - Checking and removing old/unhealthy nodes

---

## Index

* [Description](https://github.com/LozanoMatheus/etcd_with_unhealthy_check#description)
* [Dependencies](https://github.com/LozanoMatheus/etcd_with_unhealthy_check#dependencies)
* [How to use](https://github.com/LozanoMatheus/etcd_with_unhealthy_check#how-to-use)
  * [Checking the ETCD version or getting etcd command help](https://github.com/LozanoMatheus/etcd_with_unhealthy_check#checking-the-etcd-version-or-getting-etcd-command-help)
  * [Running the ETCD](https://github.com/LozanoMatheus/etcd_with_unhealthy_check#running-the-etcd)

---

## Description

The intention of this project is to check and remove old and unhealthy nodes on ETCD cluster.

This project is an evaluation for ETCD auto-health cluster.

## Dependencies

* [Discovery token](https://coreos.com/os/docs/latest/cluster-discovery.html) - To use "auto discovery" feature during the bootstrap

> _Note: This feature is just for a "fresh" cluster, not for add/remove/refresh nodes._

## How to use

By default, it will start etcd cluster.

### Checking the ETCD version or getting etcd command help

```bash
docker run --rm -it etcd_with_unhealthy_check --version
docker run --rm -it etcd_with_unhealthy_check --help
```

### Running the ETCD

By default, you can set up three variable. They're `MY_CLUSTER_TOKEN`, `MY_DISCOVERY_TOKEN` and `MY_IP`. The most important to bootstrap the cluster is `MY_DISCOVERY_TOKEN`, basically it will generate an URL to other nodes can communicate and find each other.

```bash
docker run --rm -d -e 'MY_DISCOVERY_TOKEN=https://discovery.etcd.io/<YOUR_DISCOVERY_TOKE>' etcd_with_unhealthy_check
```

> _Note: If you don't pass the var `MY_DISCOVERY_TOKEN`, each node will be a single node/cluster._

### Using your own configurations

It's also possible to run the ETCD without the default configurations.

```bash
docker run --rm etcd_with_unhealthy_check \
    --listen-peer-urls "http://127.0.0.1:2380" \
    --listen-client-urls "http://127.0.0.1:2379,http://127.0.0.1:2379" \
    --name "node_mxh2e2-my-etcd" \
    --initial-cluster-token node_mxh2e2 \
    --initial-advertise-peer-urls "http://127.0.0.1:2380" \
    --advertise-client-urls "http://127.0.0.1:2379" \
    --discovery "https://discovery.etcd.io/<YOUR_DISCOVERY_TOKE>" \
    --discovery-fallback exit
```

> _Note: It will replace all default configurations, it's not possible to mix them. For more configuration, please check the [official ETCD documentation](https://github.com/etcd-io/etcd/blob/master/Documentation/docs.md)._
