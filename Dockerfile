ARG TAG="3.11"
FROM alpine:${TAG}

RUN apk add -fU --no-cache \
		openssh \
		runit \
		tini \
		zerotier-one

ARG PWD="/opt/components"
WORKDIR ${PWD}
ADD components .
RUN chmod -v a+x $(find . -name "run" 2> /dev/null)

ENTRYPOINT ["tini", "--"]
CMD ["runsvdir", "."]

RUN ssh-keygen -A
