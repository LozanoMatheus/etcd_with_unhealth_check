FROM centos

ARG ETCD_VERSION="${ETCD_VERSION:-3.3.11}"

RUN yum -y -q install "etcd-${ETCD_VERSION}"\* epel-release gettext \
    && yum -y -q install jq \
    && yum clean all \
    && rm -rf /var/cache/yum/ /tmp/{yum_*,*.log}

COPY entrypoint.sh.template unhealth_nodes.sh /opt/

RUN MY_CLUSTER_TOKEN="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13)" MY_DISCOVERY_TOKEN="$(curl -s https://discovery.etcd.io/new?size=3)" envsubst '$MY_CLUSTER_TOKEN,$MY_DISCOVERY_TOKEN' < /opt/entrypoint.sh.template > /opt/entrypoint.sh \
    && chmod +x /opt/entrypoint.sh /opt/unhealth_nodes.sh

ENTRYPOINT [ "/opt/entrypoint.sh" ]
CMD [ "" ]