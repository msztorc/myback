#!/bin/bash

# MyBack-db is part of MyBack project - simple backup tools for DevOps
# This Bash script is designed for daily databases backup
# author: Miroslaw Sztorc <mirek.sztorc@gmail.com>
# https://github.com/msztorc/myback
# License: MIT

TIMESTAMP=$(date +"%F")

VERBOSE=0
CONFIG_FILE=myback.conf

# dump databases function
dump_db()
{

	if [ $MYSQLDUMP_ALL == 1 ]; then
		if [ $VERBOSE == 1 ]; then
			printf "Dumping all databases except: $EXCLUDE_DB\n"
		fi
	else
		if [ $VERBOSE == 1 ]; then
			printf "Dumping selected databases: $INCLUDE_DB\n"
		fi
	fi

	if [ $MYSQLDUMP_ALL == 1 ]; then
		dbs=`$MYSQL --defaults-extra-file=$EXTRA_FILE -e "SHOW DATABASES;" | grep -Ev "$EXCLUDE_DB"`
	else
		dbs=$INCLUDE_DB
	fi

	# create a backup path
	BACKUP_PATH="$BACKUP_OUTDIR$TIMESTAMP/database"
	mkdir -p "$BACKUP_PATH"
	
	for db in $dbs; do
		if [ $VERBOSE == 1 ]; then
			printf "Dumping '$db' database...\n"
			if [ $DBDUMP_GZIP == 1 ]; then
				$MYSQLDUMP --defaults-extra-file=$EXTRA_FILE --force --databases $db | gzip > "$BACKUP_PATH/$db.gz"
			else
				$MYSQLDUMP --defaults-extra-file=$EXTRA_FILE --force --databases $db > "$BACKUP_PATH/$db.sql"
			fi
		fi
	done

}

while getopts ":vc:" opt; do

  case $opt in
    c)
      CONFIG_FILE=$OPTARG
      ;;
    v)
		VERBOSE=1
		;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

# Read config file
if [ $VERBOSE == 1 ]; 
then 
	printf "Reading config file: $CONFIG_FILE\n" 
fi
. $CONFIG_FILE

# run db-backup
dump_db
