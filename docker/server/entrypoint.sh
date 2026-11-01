#!/bin/sh
# The EULA is only accepted when EULA=1 is set explicitly.
if [ "${EULA:-}" = "1" ]; then
    exec /usr/local/bin/basalt --accept-eula "$@"
fi
exec /usr/local/bin/basalt "$@"
