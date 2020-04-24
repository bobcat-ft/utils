#!/bin/bash

# drivermgr.sh
#
# Load and remove kernel modules.
#
# Usage: drivermgr.sh load <directory>
#        drivermgr.sh remove <directory>
# 
# This script assumes that the kernel modules we want to load
# live in /lib/modules/<directory>. By convention, <directory>
# matches the name of the device tree overlay that the kernel
# modules are associated with. 
#
# author Trevor Vannoy
# copyright 2020 Flat Earth Inc
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Trevor Vannoy
# Flat Earth Inc
# 985 Technology Blvd
# Bozeman, MT 59718
# support@flatearthinc.com

BASE_MODULES_PATH=/lib/modules
VERBOSE=0

# Load kernel modules
#
# This loads all modules in the user-provided directory
function load() {
    for module in $MODULES_PATH/*.ko; do
        if [ $VERBOSE -eq 1 ]; then
            echo "loading kernel module: $module"
        fi
        insmod $module
    done
}

# Remove kernel modules
#
# This removes all modules in the user-provided directory
function remove() {
    for module in $MODULES_PATH/*.ko; do
        if [ $VERBOSE -eq 1 ]; then
            echo "removing kernel module: $module"
        fi
        rmmod $module
    done
}

# Print verbose usage help
function usage() {
    echo "usage: drivermgr [-h] [-v] <command> directory"
    echo
    echo "Load and remove kernel modules."
    echo 
    echo "commands:"
    echo "  load            load kernel module(s)"
    echo "  remove          remove kernel module(s)"
    echo
    echo "positional arguments:"
    echo "  directory       directory name in /lib/modules/ that contains the modules to be loaded"
    echo 
    echo "optional arguments:"
    echo "  -h, --help      display this help text"
    echo "  -v, --verbose   print more details about what's going on"
}

# Print brief usage help
#
# Primarily for when user's invoke the script incorrectly.
function short_usage() {
    echo "usage: drivermgr [-h] [-v] <command> directory"
}

# argument parsing
for arg in "$@"; do
    case $arg in
        -h | --help)
        usage
        exit
        ;;
        -v | --verbose)
        VERBOSE=1
        # pop argument off the argument array "$@"
        shift
        ;;
        --*)
        echo "Unrecognized argument: $arg" 1>&2
        echo
        short_usage
        exit 1
        ;;
        *)
        # add positional argument to positional arguments array for later
        POSITIONAL_ARGS+=("$1")
        # pop argument off the argument array "$@"
        shift
        ;;
    esac
done

if [ ${#POSITIONAL_ARGS[*]} -eq 0 ]; then
    # print help when no arguments are supplied
    usage
    exit 1
elif [ ${#POSITIONAL_ARGS[*]} -ne 2 ]; then
    # make sure the user supplied 2 arguments
    echo "Incorrect number of positional arguments." 1>&2
    echo
    short_usage
    exit 1
fi

# grab command and modules directory name from the positional arguments
COMMAND=${POSITIONAL_ARGS[0]}
MODULES_PATH=$BASE_MODULES_PATH/${POSITIONAL_ARGS[1]}

# run the command
case $COMMAND in
    load)
    load
    ;;
    remove)
    remove
    ;;
    *)
    echo "Incorrect command. Must be either \"load\" or \"remove\"." 1>&2
    echo
    short_usage
    exit 1
    ;;
esac
