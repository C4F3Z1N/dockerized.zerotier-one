ARG TAG="3.12"
FROM alpine:${TAG}

ARG INSTALL_CMD="apk add -fU --no-cache"

RUN ${INSTALL_CMD} gettext openssh-client openssh-server-pam runit tini zerotier-one

ARG PWD="/opt/services"
WORKDIR ${PWD}
ADD services .
RUN find . -name "run" | xargs chmod -v a+x

ENTRYPOINT ["tini", "--"]
CMD ["runsvdir", "."]

HEALTHCHECK --start-period=30s --interval=1m --timeout=15s \
	CMD test "$(zerotier-cli info | grep -io 'online')"

ARG SSHD_PORT=22
ENV SSHD_PORT=${SSHD_PORT}
