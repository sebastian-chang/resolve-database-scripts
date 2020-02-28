#!/bin/sh

# List of project names in Resolve database

# Variables

#---For PostGres 9.5---#
#/Library/PostgreSQL/9.5/pgAdmin3.app/Contents/SharedSupport/psql -U postgres -t -c "select datname from pg_database" >> /tmp/databaseNames.txt

#---For PostGres 8.4---#
/Library/PostgreSQL/8.4/pgAdmin3.app/Contents/SharedSupport/psql -U postgres -t -c "select datname from pg_database" > /tmp/databaseNames.txt

databaseNameArray=( $(cat /tmp/databaseNames.txt | cut -d ' ' -f2) )

for i in "${!databaseNameArray[@]}"
do
	#----Change Resolve Database name here----#
	resolveDatabaseName="${databaseNameArray[i]}"
	
	echo "$resolveDatabaseName" >> ~/Desktop/OldResolveDatabaseProjects.txt
	/Library/PostgreSQL/8.4/pgAdmin3.app/Contents/SharedSupport/psql -U postgres "$resolveDatabaseName" -c "select \"ProjectName\" from \"SM_Project\"" >> ~/Desktop/OldResolveDatabaseProjects.txt
#	/Library/PostgreSQL/9.5/pgAdmin3.app/Contents/SharedSupport/psql -U postgres "$resolveDatabaseName" -c "select \"ProjectName\" from \"SM_Project\"" >> ~/Desktop/OldResolveDatabaseProjects.txt
	
done

echo All project names have been exported.

exit