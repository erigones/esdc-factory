#!/bin/bash

ZOOBIN="${BASH_SOURCE-$0}"
ZOOBIN="$(dirname "${ZOOBIN}")"
ZOOBINDIR="$(cd "${ZOOBIN}"; pwd)"

if [ -e "$ZOOBIN/../libexec/zkEnv.sh" ]; then
  . "$ZOOBINDIR"/../libexec/zkEnv.sh
else
  . "$ZOOBINDIR"/zkEnv.sh
fi

"$JAVA" "-Dzookeeper.log.dir=${ZOO_LOG_DIR}" \
	"-Dzookeeper.root.logger=${ZOO_LOG4J_PROP}" \
	-cp "$CLASSPATH" $CLIENT_JVMFLAGS $JVMFLAGS \
	org.apache.zookeeper.server.auth.DigestAuthenticationProvider "$@"
