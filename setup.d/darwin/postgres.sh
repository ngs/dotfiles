#!/bin/sh

set -eu

psql postgres -c "SELECT * FROM pg_shadow" | grep "postgres"; \
if [ $? -ne 0 ]; then \
  psql postgres -c "CREATE USER postgres SUPERUSER"; \
fi
