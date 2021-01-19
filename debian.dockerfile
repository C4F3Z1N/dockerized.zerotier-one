ARG TAG="stable-slim"
FROM debian:${TAG}

ARG DEBIAN_FRONTEND="noninteractive"
ARG INSTALL_CMD="apt-get install -fy --no-install-recommends"
ARG UPDATE_CMD="apt-get update --fix-missing"

VOLUME ["/var/cache/apt", "/var/lib/apt", "/tmp"]

ARG GPG_KEY="https://github.com/zerotier/ZeroTierOne/raw/master/doc/contact%40zerotier.com.gpg"
ADD ${GPG_KEY} /tmp/key.gpg

RUN ${UPDATE_CMD} && ${INSTALL_CMD} gnupg2 s6 && \
	export $(grep "VERSION_CODENAME" /etc/os-release) && \
	echo "deb http://download.zerotier.com/debian/${VERSION_CODENAME} ${VERSION_CODENAME} main" \
		> /etc/apt/sources.list.d/zerotier.list && \
	apt-key add /tmp/key.gpg && \
	${UPDATE_CMD} && ${INSTALL_CMD} zerotier-one

CMD ["s6-svscan"]

ARG PWD="/opt/services"
WORKDIR ${PWD}
ADD services .
RUN find . -name "run" | xargs chmod -v a+x

HEALTHCHECK --start-period=30s --interval=1m --timeout=15s \
	CMD test "$(zerotier-cli info | grep -io 'online')"
