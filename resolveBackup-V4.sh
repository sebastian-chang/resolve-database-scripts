#!/bin/sh

# Hourly backup only

# Variables

#---For PostGres 9.5---#
# /Library/PostgreSQL/9.5/pgAdmin3.app/Contents/SharedSupport/psql -U postgres -t -c "select datname from pg_database" >> /tmp/databaseNames.txt

#---For PostGres 8.4---#
# /Library/PostgreSQL/8.4/pgAdmin3.app/Contents/SharedSupport/psql -U postgres -t -c "select datname from pg_database" > /tmp/databaseNames.txt

# databaseNameArray=( $(cat /tmp/databaseNames.txt | cut -d ' ' -f2) )
timeStamp=$(date +"%Y%m%d%H%M")

# for i in "${!databaseNameArray[@]}"
# do
	#----Change Resolve Database name here----#
	resolveDatabaseName="201910"	
	#-----------------------------------------#
	fileName="$timeStamp""-""$resolveDatabaseName"".backup"
	localFilePath="/Volumes/Resolve Backup Drive/Day Backups/""$resolveDatabaseName"
	fullLocalFilePath="$localFilePath""/""$fileName"
# 	remoteBackupPath="/Resolve-Backups/""$resolveDatabaseName"
	#-----------------------------------------#

	# Creates local folders for Resolve database in case folder doesnt exist

	if [ ! -d "$localFilePath" ]
	then
		mkdir "$localFilePath"
	fi
	
	echo Backup folders are in place

	#-----------------------------------------#

	# Create a database dump of specific Resolve database and compress using pg_dump compression option

	#---For PostGres 9.5---#
	/Library/PostgreSQL/9.5/pgAdmin3.app/Contents/SharedSupport/pg_dump --host localhost --username postgres "$resolveDatabaseName" --blobs --file "$fullLocalFilePath" --format=custom --no-password --verbose 2> "/var/log/Resolve Logs/""$resolveDatabaseName""-Daily-""$timeStamp"".log"

	#---For PostGres 8.4---#
# 	/Library/PostgreSQL/8.4/pgAdmin3.app/Contents/SharedSupport/pg_dump --host localhost --username postgres $resolveDatabaseName --blobs --file $fullLocalFilePath --format=custom --no-password
	
	echo Finished with Resolve database dump of $resolveDatabaseName

	# Check the number of files of local and remote folders.  If more than 4 files exist in local folder.

	cd "$localFilePath"
	ls -at *.backup | sed -e '1,4d' | xargs -I {} rm -- {}

	echo Deleted any old backups.
	echo All processes finished at $(date)

# done

exit