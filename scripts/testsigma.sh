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

    STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.result // .status')

    echo "Current Testsigma status: $STATUS"

if [ "$STATUS" = "SUCCESS" ]; then
    echo "Testsigma execution passed"
    exit 0

elif [ "$STATUS" = "FAILURE" ]; then
    echo "Testsigma execution failed"
    exit 1

elif [ "$STATUS" = "ABORTED" ] || [ "$STATUS" = "STOPPED" ]; then
    echo "Testsigma execution stopped: $STATUS"
    exit 1

else
    echo "Test is still running. Waiting 10 seconds..."
    sleep 10
fi

done



echo
echo "Testsigma execution request completed"
