#!/bin/bash

echo "Testsigma script has started"

TEST_PLAN_ID="5398"

echo "Test Plan ID: $TEST_PLAN_ID"
echo "Starting Testsigma Test Plan..."

RESPONSE=$(curl -s -X POST \
  -H "Content-type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TESTSIGMA_API_KEY" \
  https://app.testsigma.com/api/v1/execution_results \
  -d "{\"executionId\":\"$TEST_PLAN_ID\"}")

echo "Testsigma response:"
echo "$RESPONSE"

EXECUTION_ID=$(echo "$RESPONSE" | jq -r '.id')

echo "Testsigma Execution ID: $EXECUTION_ID"

echo "Checking Testsigma execution status..."

STATUS_RESPONSE=$(curl -s -X GET \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $TESTSIGMA_API_KEY" \
  "https://app.testsigma.com/api/v1/execution_results/$EXECUTION_ID")

echo "Testsigma status response:"
echo "$STATUS_RESPONSE"

echo
echo "Testsigma execution request completed"
