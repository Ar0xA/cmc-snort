#!/bin/bash
# Clean up logs older than x days

DIR=/var/log/snort
AGE=30

/usr/bin/find ${DIR} -type f  -mtime +${AGE} -exec rm {} \;

#let snort rotate itself, does not work for alert logs since they have no epoch in their filename
kill -HUP `pidof snort`
