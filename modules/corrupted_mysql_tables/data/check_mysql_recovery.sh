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