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


# ==========================================
# Generate PDF Report
# ==========================================

echo
echo "Generating Testsigma PDF report..."

REPORT_API="https://app.testsigma.com/api/v1/reports/execution_result/$EXECUTION_ID?format=pdf&screenshot=FAILED_STEPS"

while true
do
    REPORT_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
        -H "Accept: application/json" \
        -H "Authorization: Bearer $TESTSIGMA_API_KEY" \
        "$REPORT_API")

    HTTP_STATUS=$(echo "$REPORT_RESPONSE" | tail -n 1)
    RESPONSE_BODY=$(echo "$REPORT_RESPONSE" | sed '$d')

    echo "Report API HTTP status: $HTTP_STATUS"
    echo "Report response:"
    echo "$RESPONSE_BODY"

    REPORT_STATUS=$(echo "$RESPONSE_BODY" | jq -r '.status')
    REPORT_URL=$(echo "$RESPONSE_BODY" | jq -r '.url // empty')
    POLL_INTERVAL=$(echo "$RESPONSE_BODY" | jq -r '.pollIntervalSeconds // 5')

    if [ "$HTTP_STATUS" = "200" ] && [ "$REPORT_STATUS" = "SUCCESS" ] && [ -n "$REPORT_URL" ]; then

        echo "PDF report generated successfully"
        echo "Report URL: $REPORT_URL"

        break

    elif [ "$HTTP_STATUS" = "202" ] && [ "$REPORT_STATUS" = "IN_PROGRESS" ]; then

        echo "Report generation is still in progress..."
        echo "Waiting $POLL_INTERVAL seconds before checking again..."

        sleep "$POLL_INTERVAL"

    else

        echo "Report generation failed"
        echo "HTTP status: $HTTP_STATUS"
        echo "Response: $RESPONSE_BODY"

        exit 1
    fi

done


# ==========================================
# Download PDF Report
# ==========================================

echo
echo "Downloading PDF report..."

curl -s -L \
    -H "Authorization: Bearer $TESTSIGMA_API_KEY" \
    "$REPORT_URL" \
    -o testsigma_execution_report.pdf

echo "PDF report downloaded successfully:"
echo "testsigma_execution_report.pdf"


# ==========================================
# Complete
# ==========================================

echo
echo "Testsigma execution request completed"


# Keep GitHub Actions status aligned with Test Plan result
if [ "$FINAL_STATUS" = "SUCCESS" ]; then
    exit 0
else
    exit 1
fi
