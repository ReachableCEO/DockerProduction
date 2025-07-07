#!/bin/bash
set -e

# Initialize data directory if it doesn't exist
if [ ! -f /app/data/easy-gate.json ]; then
    echo "Initializing Easy-gate with default configuration..."
    cp /tmp/data/easy-gate.json /app/data/
    chown cloudron:cloudron /app/data/easy-gate.json
fi

# Set environment variables
export EASY_GATE_CONFIG="/app/data/easy-gate.json"
export EASY_GATE_ROOT_PATH="/app/data"
export EASY_GATE_BEHIND_PROXY="true"

echo "Starting Easy-gate with configuration at ${EASY_GATE_CONFIG}..."
echo "Easy-gate is configured to run behind a proxy (EASY_GATE_BEHIND_PROXY=true)"

# Run the application
exec /app/code/easy-gate