#!/bin/bash

# GLOBAL VARIABLES (YEAH, I KNOW THIS IS A BAD PRACTICE :D)
ARCHIVE_DIR='/archive'


# UTILITY FUNCTIONS
guide() {
  # GUIDE HOW TO RUN THE SCRIPT.
  echo "HOW TO USE: ${0} [-dra] USERNAME [USERNAME] ... " >&2
  echo 'Disable a local Linux account.' >&2
  echo ' -d  Deletes the account instead of disabling it.' >&2
  echo ' -r  Removes the home directory associated with the account.' >&2
  echo ' -a  Creates an archive of the home directory associated with the account.' >&2
  exit 1
}


# CHECK IF THE SCRIPT IS BEING USED BY THE ROOT USER
if [[ ${UID} -gt 0 ]]
then
  echo 'Use the root account instead. Please try again.' >&2
  exit 1
fi

# OPTIONS PROVIDED BY THE USER
while getopts dra opt; do
  case ${opt} in
    d) DELETE_USER='true' ;;
    r) DELETE_HOME='-r' ;;
    a) ARCHIVE='true' ;;
    ?) guide ;;
  esac
done

# SHIFTING THE OPTION INDEX FOR THE REST OF ARGUMENTS.
shift $(( OPTIND - 1 ))


# IF THE USER DIDN'T PROVIDE AT LEAST ONE ARGUMENT. 
if [[ ${#} -lt 1 ]]
then
  guide
fi

# LOOP THROUGH ALL THE ARGUMENTS (USERNAMES) PROVIDED.
for USERNAME in ${@}
do
  echo "Processing user: ${USERNAME}"

  # MAKE SURE THE UID OF THE ACCOUNT IS NOT A SYSTEM ACCOUNT.
  USERID=$(id -u ${USERNAME})
  if [[ "${USERID}" -lt 1000 ]]
  then
    echo "Unable to process ${USERNAME}: ${USERID}. This won't work for system account." >&2
    exit 1
  fi

  # CREATE AN ARCHIVE IF INCLUDED AS AN OPTION
  if [[ ${ARCHIVE} = 'true' ]]
  then
    # ATTACH THIS IN THE ARCHIVE_DIR
    if [[ ! -d "${ARCHIVE_DIR}" ]]
    then
      echo "Creating ${ARCHIVE_DIR} archive directory."
      mkdir -p ${ARCHIVE_DIR}
      if [[ ${?} -ne 0 ]]
      then
        echo "Failed to create ${ARCHIVE_DIR} archive directory.." >&2
        exit 1
      fi
    fi
    
    # ARCHIVE THE HOME DIRECTORY AND MOVE IT TO ARCHIVE_DIR
    HOME_DIR="/home/${USERNAME}"
    ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz"
    if [[ -d "${HOME_DIR}" ]]
    then
      echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
      tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null
      if [[ "${?}" -ne 0 ]]
      then
        echo "Failed to create ${ARCHIVE_FILE} archive file." >&2
        exit 1
      fi
    else
      echo "${HOME_DIR} doesn't exists or it's not a directory." >&2
      exit 1
    fi 
  fi

  if [[ "${DELETE_USER}" = 'true' ]]
  then
    # DELETE THE USER
    userdel ${DELETE_HOME} ${USERNAME}
    if [[ "${?}" -ne 0 ]]
    then
      echo "Account deletion for ${USERNAME} failed." >&2
      exit 1
    fi
    echo "Successfully deleted ${USERNAME} account."
  else
    chage -E 0 ${USERNAME}
    if [[ "${?}" -ne 0 ]]
    then
      echo "Account disable for ${USERNAME} failed." >&2
      exit 1
    fi
    echo "The account ${USERNAME} disabled."
  fi
done

exit 0









