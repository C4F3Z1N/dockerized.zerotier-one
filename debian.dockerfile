ARG TAG="stable-slim"
FROM debian:${TAG}

ARG DEBIAN_FRONTEND="noninteractive"
ARG INSTALL_CMD="apt-get install -fy --no-install-recommends"
ARG UPDATE_CMD="apt-get update --fix-missing"

VOLUME ["/var/cache/apt", "/var/lib/apt"]

RUN ${UPDATE_CMD} && ${INSTALL_CMD} \
		gettext-base \
		gnupg2 \
		runit \
		ssh \
		tini

ARG GPG_KEY="https://github.com/zerotier/ZeroTierOne/raw/master/doc/contact%40zerotier.com.gpg"
ADD ${GPG_KEY} /tmp/key.gpg
RUN apt-key add /tmp/key.gpg && \
	echo "deb http://download.zerotier.com/debian/stretch stretch main" \
		> /etc/apt/sources.list.d/zerotier.list && \
	${UPDATE_CMD} && ${INSTALL_CMD} zerotier-one

ARG PWD="/opt/services"
WORKDIR ${PWD}
ADD services .
RUN find . -name "run" | xargs chmod -v a+x && \
	mkdir -pv /run/sshd

ENTRYPOINT ["tini", "--"]
CMD ["runsvdir", "."]

HEALTHCHECK --start-period=30s --interval=1m --timeout=15s \
	CMD test "$(zerotier-cli info | grep -io 'online')"

ARG SSHD_PORT=22
ENV SSHD_PORT=${SSHD_PORT}
