### docker build --pull -t rhel7/mattermost .
# This is a Dockerfile to be used with OpenShift3
FROM registry.access.redhat.com/rhel7
MAINTAINER Red Hat Systems Engineering <refarch-feedback@redhat.com>
# based on the works of Christoph Görn <goern@redhat.com> & Takayoshi Kimura <tkimura@redhat.com>
ENV container docker
ENV MATTERMOST_VERSION 3.6.0
ENV MATTERMOST_VERSION_SHORT 360

LABEL Component="mattermost" \
      Name="rhel7/mattermost-${MATTERMOST_VERSION_SHORT}" \
      Version="${MATTERMOST_VERSION}" \
      Release="1" \
      io.k8s.description="Mattermost is an open source, self-hosted Slack-alternative" \
      io.k8s.display-name="Mattermost {$MATTERMOST_VERSION}" \
      io.openshift.expose-services="8065:mattermost" \
      io.openshift.tags="mattermost,slack"

ENV APP_ROOT=/opt/mattermost \
    USER_NAME=mattermost \
    USER_UID=10001
ENV PATH=$PATH:${APP_ROOT}/bin
RUN mkdir -p ${APP_ROOT}/etc ${APP_ROOT}/data
COPY user_setup /tmp/
COPY bin/ ${APP_ROOT}/bin/
COPY config.json ${APP_ROOT}/config/config.json
RUN yum clean all && yum-config-manager --disable \* &> /dev/null && \
    yum-config-manager --enable rhel-7-server-rpms &> /dev/null && \
    yum -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
    yum -y install --setopt=tsflags=nodocs tar && \
    yum clean all
RUN cd /opt && \
    curl -LO https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \
    tar xf mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \
    rm mattermost-team-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \
    chmod -R ug+x ${APP_ROOT}/bin ${APP_ROOT}/etc /tmp/user_setup && \
    /tmp/user_setup

USER ${USER_UID}
WORKDIR ${APP_ROOT}
### arbitrary uid recognition at runtime - for OpenShift deployments
RUN sed "s@${USER_NAME}:x:${USER_UID}:0@${USER_NAME}:x:\${USER_ID}:\${GROUP_ID}@g" /etc/passwd > ${APP_ROOT}/etc/passwd.template
EXPOSE 8065
ENTRYPOINT [ "uid_entrypoint" ]
CMD mattermost-launch.sh