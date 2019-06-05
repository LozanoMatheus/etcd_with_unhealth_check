FROM centos

ARG ETCD_VERSION="${ETCD_VERSION:-3.3.11}"

RUN yum -y -q install "etcd-${ETCD_VERSION}"\* epel-release \
    && yum -y -q install jq \
    && yum clean all \
    && rm -rf /var/cache/yum/ /tmp/{yum_*,*.log}

COPY entrypoint.sh unhealthy_nodes.sh /opt/

RUN chmod +x /opt/entrypoint.sh /opt/unhealthy_nodes.sh

ENTRYPOINT [ "/opt/entrypoint.sh" ]
CMD [ "" ]
