#!/usr/bin/env bash
set -euo pipefail

IMAGE="$1"

# Resolve digest from registry (force pull to avoid local cache issues)
DIGEST=$(crane digest "$IMAGE" --platform=linux/amd64)
FULL_REF="${IMAGE%@*}@$DIGEST"

echo "[SECURE-RUN] Checking signature for $FULL_REF"

if cosign verify --key cosign.pub "$FULL_REF" >/tmp/cosign.log 2>&1; then
    echo "[SECURE-RUN] Verified. Running container..."
    docker run --rm "$FULL_REF"
else
    echo "[SECURE-RUN] Verification failed!"
    cat /tmp/cosign.log
    exit 1
fi
