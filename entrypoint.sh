#! /bin/bash

cd /
pm2 start w2t.js --watch
pm2 monit
