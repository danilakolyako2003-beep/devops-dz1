#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

prefix=kolyako-01
for container in "$prefix-web" "$prefix-db"; do
  if docker container inspect "$container" >/dev/null 2>&1; then
    docker rm -f "$container"
  fi
done

docker build --progress=plain --build-arg VERSION=2.0 -t "$prefix/probe:2.0" .
docker volume create "$prefix-data"
docker run -d --name "$prefix-db" -p 8005:5432 \
  -e POSTGRES_PASSWORD=lab -e POSTGRES_DB=lab \
  -v "$prefix-data:/var/lib/postgresql/data" postgres:16-alpine
docker run -d --name "$prefix-web" -p 8003:5001 \
  --add-host host.docker.internal:host-gateway \
  -e APP_PORT=5001 -e MARKER=sitelab \
  -e DATABASE_URL=postgresql://postgres:lab@host.docker.internal:8005/lab \
  "$prefix/probe:2.0"

SECONDS=0
until curl -fsS -m 3 http://127.0.0.1:8003/notes 2>/dev/null; do
  if (( SECONDS >= 60 )); then
    curl -sS -m 7 http://127.0.0.1:8003/notes || true
    exit 1
  fi
  sleep 2
done
