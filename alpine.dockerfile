ARG TAG="3.12"
FROM alpine:${TAG}

RUN apk add -fU --no-cache s6 zerotier-one

CMD ["s6-svscan"]

ARG PWD="/opt/services"
WORKDIR ${PWD}
ADD services .
RUN find . -name "run" | xargs chmod -v a+x

HEALTHCHECK --start-period=30s --interval=1m --timeout=15s \
	CMD test "$(zerotier-cli info | grep -io 'online')"
