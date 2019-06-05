#!/usr/bin/env bash

declare -r MY_CLUSTER_TOKEN="${MY_CLUSTER_TOKEN:-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13)}"
declare -r MY_DISCOVERY_TOKEN="${MY_DISCOVERY_TOKEN:-$(curl -s https://discovery.etcd.io/new?size=3)}"
declare -r MY_IP="${MY_IP:-$(cat /proc/net/fib_trie | grep '|--' | grep -vE -m 1 ' 127|\.0[^0-9.]*$|\.255[^0-9.]*$' | awk -F' ' '{print $2}')}"
declare -r LOG_FILE="/tmp/${0//.sh/}_$(date +'%Y%m%d').log"

function log_msg() {
  echo "$(date +'%Y-%m-%d %T.%6N')" $@ | tee -a "${LOG_FILE}"
}

function check_unhealty() {
  while ps -p $! &> /dev/null ; do
    sleep 30s
    log_msg "I | unhealthy_nodes: Running the unhealthy node check"
    /opt/unhealthy_nodes.sh
  done
}

if [[ ! -z "${@// /}" ]]; then
  etcd "${@}" &
  declare -r ETCD_PID="$(echo $!)"
else
  etcd \
    --listen-peer-urls "http://${MY_IP}:2380" \
    --listen-client-urls "http://${MY_IP}:2379,http://127.0.0.1:2379" \
    --name "node_${MY_CLUSTER_TOKEN}-${HOSTNAME}" \
    --initial-cluster-token ${MY_CLUSTER_TOKEN} \
    --initial-advertise-peer-urls "http://${MY_IP}:2380" \
    --advertise-client-urls "http://${MY_IP}:2379" \
    --discovery "${MY_DISCOVERY_TOKEN}" \
    --discovery-fallback exit &
  declare -r ETCD_PID="$(echo $!)"
fi

sleep 30s

ps -p "${ETCD_PID}" &> /dev/null
[[ $? -eq 0 ]] && check_unhealty || exit 0
