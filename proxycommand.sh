#!/bin/sh -e

CONTAINER_ID=$(docker ps | awk '/zerotier/ {print $1}' | tail -n 1)
CONTAINER_PORT=$(docker port ${CONTAINER_ID} | awk -F ':' "{print \$NF}")
CONTAINER_USER=$(docker exec ${CONTAINER_ID} whoami)

TMP_KEY=$(docker exec ${CONTAINER_ID} mktemp -u)
docker cp ~/.ssh/id_rsa.pub ${CONTAINER_ID}:${TMP_KEY}
docker exec ${CONTAINER_ID} sh -c "touch ~/.ssh/authorized_keys"
docker exec ${CONTAINER_ID} sh -c "sort -u ~/.ssh/authorized_keys ${TMP_KEY} > ~/.ssh/authorized_keys"

CONFIG=$(mktemp -u)
cat << EOF > ${CONFIG}
Host ${2}
User ${1}
ForwardAgent yes
EOF

if [ "$(ps -o comm -p ${PPID} | grep -io ssh)" ]; then
	exec ssh -o StrictHostKeyChecking=no -A -F ${CONFIG} -W ${2}:${3} ${CONTAINER_USER}@localhost -p ${CONTAINER_PORT}
else
	echo "ProxyCommand ssh -A -o StrictHostKeyChecking=no -W %h:%p %r@localhost -p ${CONTAINER_PORT}" >> ${CONFIG}
	exec ssh -A -F ${CONFIG} ${1}@${2} -p ${3:-22}
fi
