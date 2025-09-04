#!/bin/bash

set -euo pipefail

# Set default port if not provided
: ${RATHOLE_SERVER_PORT:=2333}

# Generate rathole.toml configuration file
cat <<EOF > /app/data/rathole.toml
[server]
bind_addr = "0.0.0.0:$RATHOLE_SERVER_PORT"
token = "$RATHOLE_SERVER_TOKEN"
EOF

# Start Rathole server
exec /usr/local/bin/rathole -c /app/data/rathole.toml
