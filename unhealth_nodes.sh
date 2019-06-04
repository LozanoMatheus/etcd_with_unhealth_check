#!/usr/bin/env bash

declare -r NODE_DOWN_FILE="/tmp/node_down"
declare -r ID_NODE_DOWN_FILE="/tmp/id_node_down"

function finish_him() {
  curl --max-time 5 -Ls http://127.0.0.1:2379/v2/keys/check_cluster -XDELETE &> /dev/null
  rm -f "${NODE_DOWN_FILE}"* "${ID_NODE_DOWN_FILE}"*
}
trap finish_him EXIT SIGHUP SIGINT SIGQUIT SIGABRT SIGKILL SIGTERM

function log_msg() {
  echo "`date +'%Y-%m-%d %T.%6N'`" $@
}

log_msg "I | unhealth_nodes: Checking if the process is already running"
check_return="$(curl --max-time 5 -Ls http://127.0.0.1:2379/v2/keys/check_cluster)"
if [[ $? -eq 28 ]]; then
  log_msg "W | unhealth_nodes: Cluster is not ready !"
  exit 28
elif [[ "$(jq -r '.message' <<< ${check_return})" != 'Key not found' ]]; then
  log_msg "W | unhealth_nodes: The check is already running !"
  exit 1
fi

log_msg "I | unhealth_nodes: Starting the ckeck list for the ETCD nodes"
curl --max-time 5 -Ls http://127.0.0.1:2379/v2/keys/check_cluster -XPUT -d value="Checking nodes" -d ttl=240 &> /dev/null

log_msg "I | unhealth_nodes: Checking for ETCD node down"
curl --max-time 5 -Ls http://127.0.0.1:2379/v2/members | jq -r '.members[].clientURLs[]' | xargs -I{} bash -c "curl --max-time 5 -Ls {}/health || echo {} >> ${NODE_DOWN_FILE}.tmp" &> /dev/null

uniq "${NODE_DOWN_FILE}.tmp" > "${NODE_DOWN_FILE}"

log_msg "I | unhealth_nodes: Node(s) down: $(</tmp/node_down)"
echo "$(<${NODE_DOWN_FILE})" | xargs -I{} bash -c "curl --max-time 5 -Ls http://127.0.0.1:2379/v2/members | jq -r '.members[] | select(.clientURLs[] == \"{}\") | .id' >> ${ID_NODE_DOWN_FILE}"

log_msg "I | unhealth_nodes: Removing the nodes down"
echo "$(<${ID_NODE_DOWN_FILE})" | xargs -I{} etcdctl member remove "{}"
