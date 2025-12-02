#!/usr/bin/env bash
set -e

# Wait for Postgres to be ready
echo "Waiting for Postgres..."
until pg_isready -h db -p 5432 -q; do
  echo "Postgres is unavailable - sleeping"
  sleep 1
done

echo "Postgres is up - running migrations and seeds..."

# Prepare DB (create + migrate) and seed
bundle exec rails db:prepare
bundle exec rails db:seed

echo "Starting Rails server..."
exec "$@"
