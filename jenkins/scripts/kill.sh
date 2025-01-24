#!/usr/bin/env sh

echo 'The following command terminates the "npm start" process using its PID'
echo '(written to ".pidfile"), all of which were conducted when "deliver.sh"'
echo 'was executed.'

if [ -f .pidfile ] && [ -s .pidfile ]; then
    set -x
    kill $(cat .pidfile)
    set +x
fi