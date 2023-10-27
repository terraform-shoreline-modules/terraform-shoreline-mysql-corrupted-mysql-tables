

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