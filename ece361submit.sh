#!/bin/bash
# Wrapper script around EECG's submitece361* commands
# Ensures necessary files exist before submitting
#
# Usage format:
#   ece361submit <lab num>
#
SCRIPT_DIR=$(cd $(dirname "$0") && pwd)
source ${SCRIPT_DIR}/echoHelpers
unset ERR

MONTH_NUM=`date +%m`
if [[ ${MONTH_NUM} -le 4 ]]; then
    EECG_SUBMIT=submitece361s
elif [[ ${MONTH_NUM} -ge 9 ]]; then
    EECG_SUBMIT=submitece361f
else
    bold_red "ERROR: No course in the summer... why are you here?"
    exit 1
fi

# Get lab number
if [[ $# -ne 1 ]]; then
    bold_blue "Usage format:"
    blue "\tece361submit <lab num>"
    exit 1
else
    LAB_NUM=$1

    # Check if directory for the lab exists
    if [[ ! -d "${SCRIPT_DIR}/lab${LAB_NUM}" ]]; then
        bold_red "ERROR: Lab ${LAB_NUM} does not exist (or submission is not ready yet)"
        exit 1
    fi
fi

# Checks if 'ERR' variable exists and has been set, and exit if so.
function checkErr() {
    if [[ $ERR ]]; then
        exit 1
    fi
}

# Ensure required files exist, exit if at least one is missing
REQ_FILES=`cat ${SCRIPT_DIR}/lab${LAB_NUM}/required-files | grep -v "^#"`
for FILE in ${REQ_FILES}; do
    if [[ ! -f ${FILE} ]]; then
        bold_red "ERROR: ${FILE} does not exist"
        ERR=1
    fi
done
checkErr

${EECG_SUBMIT} ${LAB_NUM} ${REQ_FILES}

# List submissions for students to confirm
bold_blue "Listing submissions..."
${EECG_SUBMIT} -l ${LAB_NUM}
