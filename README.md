
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Corrupted MySQL Tables
---

Corrupted MySQL Tables refer to a type of incident where there is an error in the data held within a MySQL table, rendering it unreadable. This can result in the server crashing when attempts are made to read from the corrupted table. This issue can occur occasionally and can cause disruption to the normal functioning of the database. The incident requires troubleshooting to identify the cause of the corruption and to recover the data held within the table.

### Parameters
```shell
export PASSWORD="PLACEHOLDER"

export USERNAME="PLACEHOLDER"

export PATH_TO_BACKUP_FILE="PLACEHOLDER"

export NAME_OF_DATABASE="PLACEHOLDER"

export PATH_TO_MYSQL_LOGFILE="PLACEHOLDER"

export PATH_TO_MYSQL_ERRORLOG="PLACEHOLDER"

export TABLE_NAME="PLACEHOLDER"

export DATABASE_NAME="PLACEHOLDER"
```

## Debug

### Step 1: Check if MySQL is running
```shell
systemctl status mysql
```

### Step 2: Check the MySQL error logs for any recent errors
```shell
tail -n 100 /var/log/mysql/error.log
```

### Step 3: Check the MySQL database for corrupted tables
```shell
mysqlcheck -u ${USERNAME} -p ${PASSWORD} --all-databases --check --silent
```

### Step 4: Check the MySQL log files for any clues
```shell
tail -n 100 /var/log/mysql/mysql.log
```

### Check to see if the DB server shutdown leading to incomplete transactions.
```shell
bash

#!/bin/bash



# Define variables

LOGFILE=${PATH_TO_MYSQL_LOGFILE}

ERRORLOG=${PATH_TO_MYSQL_ERRORLOG}



# Check for incomplete transactions in the log file

if grep -q "InnoDB: Database was not shutdown normally!" "$ERRORLOG"; then

    echo "Incomplete transactions found in error log. Checking for additional details..."

    # Check for incomplete transactions in the MySQL log file

    if grep -q "InnoDB: Starting recovery" "$LOGFILE"; then

        echo "InnoDB recovery process started. MySQL server was likely not shut down properly."

    else

        echo "No recovery process found. MySQL server may have been shut down properly."

    fi

else

    echo "No incomplete transactions found in error log. MySQL server may have been shut down properly."

fi


```

### Step 5: Attempt to repair any corrupted tables using mysqlcheck
```shell
mysqlcheck -u ${USERNAME} -p ${PASSWORD} --all-databases --repair --silent
```

## Repair

### Restore from Backup: If you have a recent backup of your MySQL database, restoring it to a point before the corruption occurred will resolve the issue. This is assuming that the backup itself is not corrupted.
```shell


#!/bin/bash



# Set variables

DB_NAME=${NAME_OF_DATABASE}

BACKUP_PATH=${PATH_TO_BACKUP_FILE}

MYSQL_USER=${USERNAME}

MYSQL_PASSWORD=${PASSWORD}



# Stop MySQL service

sudo service mysql stop



# Restore backup

sudo mysql -u $MYSQL_USER -p$MYSQL_PASSWORD $DB_NAME < $BACKUP_PATH



# Start MySQL service

sudo service mysql start


```

### Repair and Optimize: MySQL has a built-in repair and optimize function that can help fix corrupted tables. You can use the following command in the MySQL client: `REPAIR TABLE tablename;` or `OPTIMIZE TABLE tablename;`. If the repair function doesn't work, try the optimize function.
```shell


#!/bin/bash



# Set variables

DATABASE=${DATABASE_NAME}

TABLE=${TABLE_NAME}



# Repair the table

mysql -u ${USERNAME} -p${PASSWORD} -e "REPAIR TABLE $DATABASE.$TABLE;"



# Check if the repair was successful

if [ $? -eq 0 ]; then

  echo "Table $TABLE in database $DATABASE has been repaired."

else

  echo "Unable to repair table $TABLE in database $DATABASE."

fi



# Optimize the table

mysql -u ${USERNAME} -p${PASSWORD} -e "OPTIMIZE TABLE $DATABASE.$TABLE;"



# Check if the optimize was successful

if [ $? -eq 0 ]; then

  echo "Table $TABLE in database $DATABASE has been optimized."

else

  echo "Unable to optimize table $TABLE in database $DATABASE."

fi


```

### Attempt the MYSQL dump and reload method for corrupted tables
```shell


#!/bin/bash

# Define variables

DATABASE=${DATABASE_NAME}

TABLE=${TABLE_NAME}

BACKUP_DIR=${PATH_TO_BACKUP_FILE}



# Create backup directory if it does not exist

mkdir -p $BACKUP_DIR



# Dump the corrupted table to a backup file

mysqldump $DATABASE $TABLE > $BACKUP_DIR/$TABLE.sql



# Drop the corrupted table

mysql -e "DROP TABLE $DATABASE.$TABLE"



# Recreate the table

mysql -e "CREATE TABLE $DATABASE.$TABLE ( ... )"



# Load the data from the backup file into the new table

mysql $DATABASE < $BACKUP_DIR/$TABLE.sql


```