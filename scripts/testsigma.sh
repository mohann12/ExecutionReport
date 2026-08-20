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

while true
do
  STATUS_RESPONSE=$(curl -s -X GET \
    -H "Accept: application/json" \
    -H "Authorization: Bearer $TESTSIGMA_API_KEY" \
    "https://app.testsigma.com/api/v1/execution_results/$EXECUTION_ID")

  RESULT=$(echo "$STATUS_RESPONSE" | jq -r '.result')

  echo "Current Testsigma status: $RESULT"

  if [ "$RESULT" = "PASSED" ] || [ "$RESULT" = "FAILED" ]; then
    break
  fi

  echo "Test is still running. Waiting 10 seconds..."
  sleep 10
done

echo "Final Testsigma result: $RESULT"

echo
echo "Testsigma execution request completed"
