#!/bin/bash


# Global variables
SERVER_LIST='./servers'
SSH_OPTIONS='-o ConnectTimeout=2'


# Utility function
usage() {
  echo "Usage: ${0} [-nsv] [-f FILE] COMMAND" >&2
  echo "Executes COMMAND as a single command on every server." >&2
  echo " -f FILE  Use FILE for the list of servers. Default ${SERVER_LIST}." >&2
  echo " -n       Dry run mode. Display the COMMAND that would have been executed and exit." >&2
  echo " -s       Execute the COMMAND using sudo on the remove server." >&2
  echo " -v       Verbose mode. Displays the server name before executing COMMAND." >&2
  exit 1
}


# Check if the user is going to use sudo. Advising to execute the file using normal account instead.
if [[ ${UID} -eq 0 ]]
then
  echo 'Please do not use this script as superuser (sudo). Try to utilize the -s option instead.' >&2
  usage
fi


# Parse the options
while getopts f:nsv opt; do
  case ${opt} in
    f) SERVER_LIST=${OPTARG} ;;
    n) DRY_RUN='true' ;;
    s) SUDO='sudo' ;;
    v) VERBOSE='true' ;;
    ?) usage ;;
  esac
done

# shift the option index to get all the remaining arguments.
shift $(( OPTIND - 1 ))

# check to see if argument is provided. guide the user if it is not provided.
if [[ ${#} -lt 1 ]]
then
  usage
fi

# anything remains
COMMAND=${@}

# Now let's check if the file provided in f option exists
if [[ ! -e ${SERVER_LIST} ]]
then
  echo "Cannot open the server list file ${SERVER_LIST}." >&2
  exit 1
fi

# Expect the best, prepare for the worst.
EXIT_STATUS='0'

# Loop through the server list.
for SERVER in $(cat ${SERVER_LIST})
do
  if [[ ${VERBOSE} = 'true' ]]
  then
    echo =================
    echo ${SERVER}
    echo =================
  fi

  SSH_COMMAND="ssh ${SSH_OPTIONS} ${SERVER} ${SUDO} ${COMMAND}"

  # check if the dry run is selected
  if [[ ${DRY_RUN} = 'true' ]]
  then
    echo "DRY RUN: ${SSH_COMMAND}"
  else
    ${SSH_COMMAND}
    SSH_EXIT_STATUS=${?}
    

    # Capture any non-zero exit status from the SSH_COMMAND and report to the user.
    if [[ ${SSH_EXIT_STATUS} -ne 0 ]]
    then
      EXIT_STATUS=${SSH_EXIT_STATUS}
      echo "Execution on ${SERVER} failed." >&2
    fi
  fi
done

exit ${EXIT_STATUS}
