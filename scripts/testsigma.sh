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
    FINAL_STATUS="$STATUS"
    break

elif [ "$STATUS" = "FAILURE" ]; then
    echo "Testsigma execution failed"
    FINAL_STATUS="$STATUS"
    break

elif [ "$STATUS" = "ABORTED" ] || [ "$STATUS" = "STOPPED" ]; then
    echo "Testsigma execution stopped: $STATUS"
    FINAL_STATUS="$STATUS"
    break

else
    echo "Test is still running. Waiting 10 seconds..."
    sleep 10
fi

done

echo "Final Testsigma result: $FINAL_STATUS"


echo
echo "Testsigma execution request completed"
