#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Function to check if a service is ready
wait_for_service() {
  local host="$1"
  local port="$2"
  local service="$3"
  
  echo "Waiting for $service to be ready..."
  until nc -z "$host" "$port"; do
    echo "$service is unavailable - sleeping"
    sleep 2
  done
  echo "$service is up - executing command"
}

# Wait for MySQL
wait_for_service db 3306 "MySQL"

# Wait for Redis
wait_for_service redis 6379 "Redis"

# Wait for SWORD Engine
wait_for_service sword_engine 8081 "SWORD Engine"

# Run database migrations
bundle exec rails db:migrate

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@" 