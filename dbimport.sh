#!/bin/bash

mysql_exec() {
  local user="$1"
  local pass="$2"
  local host="$3"
  local port="$4"
  local db="$5"
  local query="$6"

  if [ -z "${query}" ]
    then
    printf "%s\n" \
      "[client]" \
      "user=${user}" \
      "password=${pass}" \
      "host=${host}" \
      "port=${port}" \
      | HOME="/sys" mysql --defaults-file=/dev/stdin -e "${db}"
  else
    printf "%s\n" \
      "[client]" \
      "user=${user}" \
      "password=${pass}" \
      "host=${host}" \
      "port=${port}" \
      "database=${db}" \
      | HOME="/sys" mysql --defaults-file=/dev/stdin -e "${query}"
  fi
}

mysqldump_exec() {
  local user="$1"
  local pass="$2"
  local db="$3"
  local port="$4"
  local host="$5"
  local file="$6"

  printf "%s\n" \
    "[client]" \
    "user=${user}" \
    "password=${pass}" \
    "host=${host}" \
    "port=${port}" \
     | HOME="/sys" mysqldump --defaults-file=/dev/stdin ${db} > ${file}
}


# Reading HOST and DB credentials from PROD wp-config.php
PROD_DB_NAME=`cat ../html/wp-config.php | grep DB_NAME | cut -d \' -f 4`
PROD_DB_HOST=`cat ../html/wp-config.php | grep DB_HOST | cut -d \' -f 4`
PROD_DB_USER=`cat ../html/wp-config.php | grep DB_USER | cut -d \' -f 4`
PROD_DB_PASS=`cat ../html/wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`
PROD_DB_PORT=3306 # or change this port to yours

# Reading HOST and DB credentials from DEV wp-config.php
DEV_DB_NAME=`cat wp-config.php | grep DB_NAME | cut -d \' -f 4`
DEV_DB_HOST=`cat wp-config.php | grep DB_HOST | cut -d \' -f 4`
DEV_DB_USER=`cat wp-config.php | grep DB_USER | cut -d \' -f 4`
DEV_DB_PASS=`cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`
DEV_DB_PORT=3306 # or change this port to yours

echo "Starting import";
echo "Dumping prod database";

mysqldump_exec $PROD_DB_USER $PROD_DB_PASS $PROD_DB_NAME $PROD_DB_PORT $PROD_DB_HOST "/tmp/dump.sql";

echo "Prod dump created";
echo "Dumping dev database";

mysqldump_exec $DEV_DB_USER $DEV_DB_PASS $DEV_DB_NAME $DEV_DB_PORT $DEV_DB_HOST "/tmp/dev.dump.sql";

echo "Dev dump /tmp/dev.dump.sql created";
echo "Droping old data";

mysql_exec $DEV_DB_USER $DEV_DB_PASS $DEV_DB_HOST $DEV_DB_PORT "DROP DATABASE IF EXISTS ${DEV_DB_NAME}; CREATE DATABASE IF NOT EXISTS ${DEV_DB_NAME}";

echo "Importing new data";

mysql_exec $DEV_DB_USER $DEV_DB_PASS $DEV_DB_HOST $DEV_DB_PORT $DEV_DB_NAME "source /tmp/dump.sql"

rm /tmp/dump.sql

read -p "Remove dev dump? [y,n]: " removedevdump
case $removedevdump in
  y|Y) rm /tmp/dev.dump.sql; echo "Dev dump was removed"
esac

echo "Done"

