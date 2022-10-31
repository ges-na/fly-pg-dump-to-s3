#!/bin/bash

set -e

_USAGE="
Usage: ./backup-db <database_url> <s3-destination>
Example:
  ./backup-db postgresql://username:password@hostname:5432/my_database s3://my-bucket-name/database_backup.sql
"

BACKUPS_TEMP_DIR="/tmp/db-backups"

# exports sql file
pg_dump_args="--no-owner --clean --no-privileges --no-sync --format=plain --compress=0"
PG_DUMP_ARGS=${PG_DUMP_ARGS:-$pg_dump_args}

database_url=$1
destination=$2

if [[ -z "$database_url" || -z "$destination" ]]; then
  echo "$_USAGE"
  exit 1
fi

if [[ -z $AWS_ACCESS_KEY_ID || -z $AWS_SECRET_ACCESS_KEY ]]; then
  echo "Required env vars: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY"
  exit 1
fi

mkdir -p "${BACKUPS_TEMP_DIR}"

backup_filename="${BACKUPS_TEMP_DIR}/pbp_database_dump.sql"

# In the future we could add a configuration to prevent deletion of existing files
rm -rf "${backup_filename}"

echo "Dumping database to ${backup_filename}"
pg_dump $PG_DUMP_ARGS \
    --dbname="${database_url}" \
    --file="${backup_filename}"

echo "Uploading backup to ${destination}"
aws s3 cp --only-show-errors "${backup_filename}" "${destination}"

rm -rf "${backup_filename}"

echo "Database backup finished!"
