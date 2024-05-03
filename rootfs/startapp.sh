#!/bin/sh

set -u # Treat unset variables as an error.

trap "exit" TERM QUIT INT

# Start
hakuneko-desktop

# Wait until it dies.
wait $!
