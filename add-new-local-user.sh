#!/bin/bash

# MAKE SURE THIS IS BEING USED AS ROOT OR SUDO
if [[ "${UID}" -ne 0 ]]
then
  echo 'Please use the root account or run this script as sudo.'
  exit 1
fi

# MAKE SURE THE USER WILL PROVIDE ARGUMENTS
if [[ ${#} -lt 1 ]]
then
  echo 'Please follow this instruction.'
  echo "Usage: ${0} USER_NAME [COMMENT] ..."
  exit 1
fi


# TAKING FIRST ARGUMENT AS USERNAME THEN SHIFT THEN TAKING ALL ARGUMENTS AS COMMENT
USER_NAME=${1}
shift
COMMENT=${@}


# GENERATING PASSWORD
RANDOM_CHARACTER=$(echo '!@#$%^&*()_-+=' | fold -w1 | shuf | head -c1)
RANDOM_PASSWORD=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c9)
PASSWORD=${RANDOM_PASSWORD}${RANDOM_CHARACTER}


useradd -c "${COMMENT}" -m ${USER_NAME}
if [[ ${?} -gt 0 ]]
then
  echo 'Something went wrong. Please try again.'
  exit 1
fi

echo "${PASSWORD}" | passwd --stdin ${USER_NAME}
if [[ ${?} -gt 0 ]]
then
  echo 'Something went wrong in password setup. Please try again.'
  exit 1
fi

passwd -e ${USER_NAME}


FILE="./${USER_NAME}"

echo " ======================" 1>> ${FILE} 2> /dev/null
echo "| Successfully Created |" 1>> ${FILE} 2> /dev/null
echo " ======================" 1>> ${FILE} 2> /dev/null
echo "Username:" 1>> ${FILE} 2> /dev/null
echo "${USER_NAME}" 1>> ${FILE} 2> /dev/null
echo 1>> ${FILE} 2> /dev/null
echo "Comment:" 1>> ${FILE} 2> /dev/null
echo "${COMMENT}" 1>> ${FILE} 2> /dev/null
echo 1>> ${FILE} 2> /dev/null
echo "Password:" 1>> ${FILE} 2> /dev/null
echo "${PASSWORD}" 1>> ${FILE} 2> /dev/null
echo 1>> ${FILE} 2> /dev/null
echo "Hostname:" 1>> ${FILE} 2> /dev/null
echo "${HOSTNAME}" 1>> ${FILE} 2> /dev/null


