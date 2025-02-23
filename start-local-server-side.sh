#!/bin/bash

(
  cd server-side || exit
  docker-compose -f docker-compose.yml up -d
)

export TRT_DB_CONN=mariadb://LOCAL_ADMIN:abc123.@localhost/theroundtable

sleep 5

output/trt-server-side/app/server_side