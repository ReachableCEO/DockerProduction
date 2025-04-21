#!/bin/bash
set -e

echo "Performing Consul Democracy backup..."

# The Cloudron backup system will automatically handle:
# 1. /app/data
# 2. PostgreSQL database

# We don't need any custom backup logic as Cloudron handles 
# both the database and the data directory.

# In case of any application-specific backup needs:

# 1. Run any pre-backup tasks
cd /app/code
RAILS_ENV=production bundle exec rake tmp:clear

# 2. Ensure all user uploads are synced
sync

echo "Backup preparation complete"
exit 0