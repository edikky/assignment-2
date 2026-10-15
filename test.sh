#!/usr/bin/env bash
# test.sh - Tests for the diagnostic Docker image
set -u

IMAGE="diagnostic-tool-test"
PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

echo "Building image..."
if ! docker build -q -t "$IMAGE" . >/dev/null 2>&1; then
    echo "FAIL: image build failed"
    exit 1
fi

# help
out=$(docker run --rm "$IMAGE" help 2>&1); rc=$?
[[ $rc -eq 0 ]] && pass "help exits 0" || fail "help exits $rc (expected 0)"
echo "$out" | grep -qi "usage" && pass "help prints usage" || fail "help missing usage text"

# system
out=$(docker run --rm "$IMAGE" system 2>&1); rc=$?
[[ $rc -eq 0 ]] && pass "system exits 0" || fail "system exits $rc (expected 0)"
echo "$out" | grep -qi "kernel" && pass "system shows kernel info" || fail "system missing kernel info"

# disk
out=$(docker run --rm "$IMAGE" disk 2>&1); rc=$?
[[ $rc -eq 0 ]] && pass "disk exits 0" || fail "disk exits $rc (expected 0)"
echo "$out" | grep -qi "filesystem" && pass "disk shows filesystem table" || fail "disk missing filesystem table"

# invalid command
docker run --rm "$IMAGE" not-a-command >/dev/null 2>&1; rc=$?
[[ $rc -eq 2 ]] && pass "invalid command exits 2" || fail "invalid command exits $rc (expected 2)"

# network without host
docker run --rm "$IMAGE" network >/dev/null 2>&1; rc=$?
[[ $rc -eq 2 ]] && pass "network without host exits 2" || fail "network without host exits $rc (expected 2)"

docker image rm "$IMAGE" >/dev/null 2>&1 || true

echo
echo "Passed: $PASS  Failed: $FAIL"
[[ $FAIL -eq 0 ]]