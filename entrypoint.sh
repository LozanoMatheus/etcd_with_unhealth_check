#!/bin/bash

MY_IP="$(cat /proc/net/fib_trie | grep '|--' | grep -vE -m 1 ' 127|\.0[^0-9.]*$|\.255[^0-9.]*$' | awk -F' ' '{print $2}')"
cat /proc/net/fib_trie | grep '|--' | grep -vE -m 1 ' 127|\.0[^0-9.]*$|\.255[^0-9.]*$' | awk -F' ' '{print $2}'

etcd \
  --listen-peer-urls "http://${MY_IP}:2380" \
  --listen-client-urls "http://${MY_IP}:2379,http://127.0.0.1:2379" \
  --name "node_test001-${HOSTNAME}" \
  --initial-cluster-token ${MY_CLUSTER_TOKEN} \
  --initial-advertise-peer-urls "http://${MY_IP}:2380" \
  --advertise-client-urls "http://${MY_IP}:2379" \
  --discovery "${MY_DISCOVERY_TOKEN}" \
  --discovery-fallback exit
