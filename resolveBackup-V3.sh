#!/bin/sh

# Nightly backup with optimization

# Variables

#---For PostGres 9.5---#
/Library/PostgreSQL/9.5/pgAdmin3.app/Contents/SharedSupport/psql -U postgres -t -c "select datname from pg_database" >> /tmp/databaseNames.txt

#---For PostGres 8.4---#
# /Library/PostgreSQL/8.4/pgAdmin3.app/Contents/SharedSupport/psql -U postgres -t -c "select datname from pg_database" > /tmp/databaseNames.txt

databaseNameArray=( $(cat /tmp/databaseNames.txt | cut -d ' ' -f2) )
timeStamp=$(date +"%Y%m%d%H%M")

for i in "${!databaseNameArray[@]}"
do
	#----Change Resolve Database name here----#
	resolveDatabaseName="${databaseNameArray[i]}"	
	#-----------------------------------------#
	fileName="$timeStamp""-""$resolveDatabaseName"".backup"
	localFilePath="/Volumes/Resolve Backup Drive/Resolve Daily Backups/""$resolveDatabaseName"
	fullLocalFilePath="$localFilePath""/""$fileName"
	remoteBackupPath="/Volumes/TBD-HOLDING/Resolve-Backups/""$resolveDatabaseName"
	#-----------------------------------------#
	
	echo Working on Resolve database "$resolveDatabaseName".

	# Creates local and remote folders for Resolve database in case folder doesnt exist

	if [ ! -d "$localFilePath" ]
	then
		mkdir "$localFilePath"
	fi
	
	ssh -i /Users/tbdadmin/.ssh/id_rsa -T tbdserver@192.168.0.100 << EOF

	if [ ! -d "$remoteBackupPath" ]
	then
		mkdir "$remoteBackupPath"
	fi
	exit
EOF
	
	echo Backup folders for "$resolveDatabaseName" are in place.

	#-----------------------------------------#

	# Create a database dump of specific Resolve database and compress using pg_dump compression option

	#---For PostGres 9.5---#
	/Library/PostgreSQL/9.5/pgAdmin3.app/Contents/SharedSupport/pg_dump --host localhost --username postgres "$resolveDatabaseName" --blobs --file "$fullLocalFilePath" --format=custom --no-password --verbose 2> "/var/log/Resolve Logs/"$resolveDatabaseName"-"$timeStamp".log"

	#---For PostGres 8.4---#
# 	/Library/PostgreSQL/8.4/pgAdmin3.app/Contents/SharedSupport/pg_dump --host localhost --username postgres "$resolveDatabaseName" --blobs --file "$fullLocalFilePath" --format=custom --no-password --verbose 2> "/var/log/Resolve Logs/"$resolveDatabaseName"-"$timeStamp".log"
	
	echo Finished with Resolve database dump of "$resolveDatabaseName".

	#-----------------------------------------#

	# Secure copy of new Resolve database dump to TBD-Holiding on TBD server

	scp -i /Users/tbdadmin/.ssh/id_rsa "$fullLocalFilePath" tbdserver@192.168.0.100:"$remoteBackupPath"

	echo Done copying "$fileName" to "$remoteBackupPath"

	#-----------------------------------------#

	# Check the number of files of local and remote folders.  If more than 10 files exist in local folder, or 100 files exist in remote folder delete oldest file

	ssh -i /Users/tbdadmin/.ssh/id_rsa -T tbdserver@192.168.0.100 << EOF

	cd "$remoteBackupPath"
	ls -at *.backup | sed -e '1,21d' | xargs -I {} rm -- {}
	exit
EOF

	cd "$localFilePath"
	ls -at *.backup | sed -e '1,7d' | xargs -I {} rm -- {}

	echo Deleted any old backups of "$resolveDatabaseName".
	
	#-----------------------------------------#
	
	# Run optimize commmands for specific Resolve database
	
	#---For PostGres 9.5---#
	/Library/PostgreSQL/9.5/bin/reindexdb --host localhost --username postgres "$resolveDatabaseName" --no-password --echo 2> "/var/log/Resolve Logs/"$resolveDatabaseName"-"$timeStamp".log"
	/Library/PostgreSQL/9.5/bin/vacuumdb --analyze --host localhost --username postgres "$resolveDatabaseName" --no-password --verbose 2> "/var/log/Resolve Logs/"$resolveDatabaseName"-"$timeStamp".log"
	
	#---For PostGres 8.4---#
# 	/Library/PostgreSQL/8.4/pgAdmin3.app/Contents/SharedSupport/reindexdb --host localhost --username postgres "$resolveDatabaseName" --no-password --echo 2> "/var/log/Resolve Logs/"$resolveDatabaseName"-"$timeStamp".log"
# 	/Library/PostgreSQL/8.4/pgAdmin3.app/Contents/SharedSupport/vacuumdb --analyze --host localhost --username postgres "$resolveDatabaseName" --no-password --verbose 2> "/var/log/Resolve Logs/"$resolveDatabaseName"-"$timeStamp".log"
	
	cd "/var/log/Resolve Logs/"
	ls -at *.log| sed -e '1,1000d' | xargs -I {} rm -- {}
	
	echo Opimization of "$resolveDatabaseName" has been completed.
	echo All processes for "$resolveDatabaseName" have finished at $(date)

done
	
	echo All Resolve databases have been backed up and optimized.

exit

/Library/PostgreSQL/9.5/pgAdmin3.app/Contents/SharedSupport/vacuumdb