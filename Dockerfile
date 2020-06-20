ARG TAG="buster-slim"
FROM debian:${TAG}

ARG DEBIAN_FRONTEND="noninteractive"
ARG INSTALL_CMD="apt-get install -fy --no-install-recommends"
ARG UPDATE_CMD="apt-get update --fix-missing"

VOLUME ["/var/cache/apt", "/var/lib/apt"]

RUN ${UPDATE_CMD} && ${INSTALL_CMD} \
		gnupg2 \
		tini \
		wget

ENTRYPOINT ["tini", "--"]

RUN echo "deb http://download.zerotier.com/debian/stretch stretch main" \
		> /etc/apt/sources.list.d/zerotier.list && \
	wget --no-check-certificate -qO - \
		"https://github.com/zerotier/ZeroTierOne/raw/master/doc/contact%40zerotier.com.gpg" \
		| apt-key add - && \
	${UPDATE_CMD} && ${INSTALL_CMD} zerotier-one

CMD ["zerotier-one"]

HEALTHCHECK --interval=1m --timeout=10s \
	CMD test "$(zerotier-cli info | grep -io 'online')"
