#!/bin/bash

################################################################
##
##   MySQL Database Backup Script 
##   Written By: Arshad
##
################################################################

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"%d%b%Y"`

################################################################
################## Update below values  ########################

DB_BACKUP_PATH='/backup/dbbackup'
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER=''
MYSQL_PASSWORD=''
DATABASE_NAME=''
TABLE_NAME='modelLogs'
BACKUP_RETAIN_DAYS=180   ## Number of days to keep local backup copy
CONDITIONAL_DATE=`date -d "7 days ago" "+%Y-%m-%d"`;
#################################################################
echo $CONDITIONAL_DATE;
sudo mkdir -p ${DB_BACKUP_PATH}/${TODAY}
echo "Backup started for database - ${DATABASE_NAME}"

if [ ! -d "${DB_BACKUP_PATH}/${TODAY}" ]; then
  echo "${DB_BACKUP_PATH}/${TODAY} does not exist."
fi

echo ${DB_BACKUP_PATH}/${TODAY};

##mysqldump -h ${MYSQL_HOST} \
##		  -P ${MYSQL_PORT} \
##		  -u ${MYSQL_USER} \
##		  -p${MYSQL_PASSWORD} \
##		  ${DATABASE_NAME} ${TABLE_NAME} | csv > ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}.csv

##sudo echo "SELECT docType FROM ${TABLE_NAME};" | mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} ! qz_timbre >${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}.csv
mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${DATABASE_NAME} -e "SELECT * FROM ${TABLE_NAME} where createdAt <= '${CONDITIONAL_DATE}';"  > ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}.csv

if [ $? -eq 0 ]; then
  mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${DATABASE_NAME} -e "DELETE FROM ${TABLE_NAME} where createdAt <= '${CONDITIONAL_DATE}';"
  echo "Database backup successfully completed"
else
  echo "Error found during backup"
fi


##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####

DBDELDATE=`date +"%d%b%Y" --date="${BACKUP_RETAIN_DAYS} days ago"`
echo $DBDELDATE;
if [ ! -z ${DB_BACKUP_PATH} ]; then
      cd ${DB_BACKUP_PATH}
      if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
            rm -rf ${DBDELDATE}
      fi
fi

### End of script ####