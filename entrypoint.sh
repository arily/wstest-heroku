#! /bin/bash

cd /
pm2 start w2t.js --watch
tail -f /dev/null
