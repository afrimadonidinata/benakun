#!/bin/sh
set -eu

until /app/benakun migrate; do
	echo "migration failed, retrying in 2s..."
	sleep 2
done

exec /app/benakun web