#!/bin/bash
#
# Renews all certificates if needed
#
# Environment Variables:
#   VERBOSE: Set to 'true' to output more information. Default is 'false'
#
# Exit codes:
#    0  No error
#   96  Problem while parsing options
#   97  Must run as root
#


set -e
set -u


# scripts have to be run as root
if [[ $EUID -ne 0 ]]; then
    echo "Must be run as root" >&2
    exit 97
fi


# -- script constants --
# set script_dir to location this script is running in
readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly script_name="$(basename $0)"
# full command before getopts
#readonly script_cmd="$*"


# -- logging functions --
# Usage: log "What to log"
log () {
    # logger will output to syslog, useful for background tasks
    #logger -s -t "${script_name}" -- "$*"
    # printf is good for scripts run manually when needed
    printf "%b\n" "$(date +"%Y-%m-%dT%H:%M:%S%z") $*"
}

# Usage: verbose "What to log if VERBOSE is true"
verbose () {
    if [[ "${VERBOSE}" == "true" ]]; then
        log "$*"
    fi
}


# -- option handling --
# Defaults
runas="${USER}"
VERBOSE=${VERBOSE:-"false"}

while getopts ":hvr:" opt; do
    case ${opt} in
    h)
        echo "Usage: $(basename $0) [OPTION] [ <filename> ]"
        echo 'renew certificates'
        echo
        echo 'Options:'
        echo '  -h  this help message'
        echo "  -r  run as specified user (default: ${runas})"
        echo '  -v  be verbose'
        exit 0
        ;;
    r)
        runas=${OPTARG}
        ;;
    v)
        VERBOSE=true
        ;;
    \?)
        echo "Invalid option: -${OPTARG}" >&2
        exit 96
        ;;
    :)
        echo "Option -${OPTARG} requires an argument" >&2
        exit 96
        ;;
    esac
done
shift $(expr ${OPTIND} - 1)
verbose "Additional arguments after options: $*"


# Make sure our umask defaults to publicly readable files so webroot method
# works.
umask 022

log "currently this does nothing"


verbose "Script ran for ${SECONDS} seconds"

exit 0

