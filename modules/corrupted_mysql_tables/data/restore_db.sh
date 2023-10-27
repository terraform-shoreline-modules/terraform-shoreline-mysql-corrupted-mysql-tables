

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