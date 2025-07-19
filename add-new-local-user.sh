#!/bin/bash

# check if they're using root

if [[ ${UID} -ne 0 ]]
then
  echo 'You are not using root account. Please try again.'
  exit 1
fi

# Check if the argument is provided.
if [[ ${#} -lt 1 ]]
then
  echo "Please provide a username and full name after script."
  echo "${0} USER_NAME [COMMENT]"
  exit 1
fi

# Create new account with the username as first argument and fullname as second argument
USER_NAME=${1}
shift
COMMENT=${@}

# Generate password
RANDOM_CHARACTER=$(echo '!@#$%^&*()-_=+' | fold -w1 | shuf | head -c1)
RANDOM_PASSWORD=$(date +%s%N | sha256sum | head -c9)
PASSWORD=${RANDOM_PASSWORD}${RANDOM_CHARACTER}

useradd -c "${COMMENT}" -m ${USER_NAME}
if [[ ${?} -ne 0 ]]
then
  echo 'Unable to create a user. Please try again.'
  exit 1
fi

echo "${PASSWORD}" | passwd --stdin ${USER_NAME}

if [[ ${?} -ne 0 ]]
then
  echo 'Unable to save a password. Please try again.'
  exit 1
fi

passwd -e ${USER_NAME}


# Show the details of the newly created account.
echo "This is the username: ${USER_NAME}"
echo "This is the comment: ${COMMENT}"
echo "This is the password: ${PASSWORD}"
echo "This is the hostname: ${HOSTNAME}"
