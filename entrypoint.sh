#! /bin/bash

cd /
pm2 start w2t.js --watch
(while true ; do echo -ne "\000" ; sleep 300 ; done ) &
