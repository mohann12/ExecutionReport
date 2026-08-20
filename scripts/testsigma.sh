#!/bin/bash

echo "Testsigma script has started"

TEST_PLAN_ID="5398"

echo "Test Plan ID: $TEST_PLAN_ID"
echo "Starting Testsigma Test Plan..."

curl -X POST \
  -H "Content-type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TESTSIGMA_API_KEY" \
  https://app.testsigma.com/api/v1/execution_results \
  -d "{\"executionId\": \"$TEST_PLAN_ID\"}"

echo
echo "Testsigma execution request completed"
