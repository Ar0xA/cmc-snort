#!/bin/bash
# Clean up logs older than x days

DIR=/var/log/snort
AGE=30

/usr/bin/find ${DIR} -type f  -mtime +${AGE} -exec rm {} \;

#let snort rotate itself
kill -HUP `pidof snort`
