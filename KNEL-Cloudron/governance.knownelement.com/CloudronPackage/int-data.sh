#!/bin/bash
set -e

echo "Initializing data directory..."

# Check if data directories exist, if not create them
mkdir -p /app/data/files
mkdir -p /app/data/images
mkdir -p /app/data/log
mkdir -p /app/data/tmp

# Generate a secret key base if it doesn't exist
if [ ! -f /app/data/secret_key_base ]; then
    echo "Generating secret key base..."
    openssl rand -hex 64 > /app/data/secret_key_base
    chmod 600 /app/data/secret_key_base
fi

# Create symlinks from app to data directory
if [ ! -L /app/code/storage ]; then
    ln -sf /app/data/files /app/code/storage
fi

if [ ! -L /app/code/public/uploads ]; then
    ln -sf /app/data/images /app/code/public/uploads
fi

if [ ! -L /app/code/log ]; then
    ln -sf /app/data/log /app/code/log
fi

if [ ! -L /app/code/tmp ]; then
    ln -sf /app/data/tmp /app/code/tmp
fi

# Set proper permissions
chown -R cloudron:cloudron /app/data

echo "Data directory initialized."