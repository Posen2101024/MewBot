#!/bin/bash
set -euo pipefail

redis-server /workspace/redis.conf

$@
