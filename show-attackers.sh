#!/bin/bash

# Make sure the file is provided
if [[ ${#} -lt 1 ]]
then
  echo 'Please provide a file to parse.' >&2
  exit 1
fi

LIMIT='10'
LOG_FILE="${1}"

# Display the CSV header
LOGIN_ATTEMPT_CSV='./login_attempt.csv'
echo "COUNT,IP,LOCATION" > ${LOGIN_ATTEMPT_CSV}

if [[ ! -e "${LOG_FILE}" ]]
then
  echo "Cannot open the log file: ${LOG_FILE}" >&2
  exit 1
fi


# Loop through the list of failed attempts and corresponding IP addresses
grep Failed ${LOG_FILE} | awk '{print $(NF -3)}' | sort | uniq -c | sort -nr | while read COUNT IP
do 
  # If the iumber of failed attempts is greated than the limit, display the count, IP and location.
  if [[ "${COUNT}" -gt "${LIMIT}" ]]
  then
    LOCATION=$(geoiplookup ${IP} | awk -F ', ' '{print $2}')
    echo "${IP}: ${COUNT} attempt. Location: ${LOCATION}"
    echo "${COUNT},${IP},${LOCATION}" >> ${LOGIN_ATTEMPT_CSV}
  fi
done

exit 0
