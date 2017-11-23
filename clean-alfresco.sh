#!/bin/bash
# Clean up an Alfresco installation
# clean-alfresco.sh [DB-NAME] [DB-USER] [ALF-DIR]

ALF_DB=$1
ALF_USER=$2
INSTALL_DIR=$3

PGHBA_PATH="/var/lib/pgsql/data/pg_hba.conf"
POSTGRES_INIT="postgresql.service"

# Some commands need to be run as another user
function su_user {
  USER=$1
  CMD=$2
  sudo su - ${1} -c "${CMD}"
}

function cleanup_database {
  ALF_DB=$1
  ALF_USER=$2
  echo "Cleaning up Database . . ."
  echo "Dropping database"
  su_user postgres "dropdb ${ALF_DB}"

  echo "Dropping user"
  su_user postgres "dropuser ${ALF_USER}"

  echo "Cleaning pg_hba.conf"
  sudo sed -i /\ ${ALF_DB}\ /d ${PGHBA_PATH}
  sudo systemctl reload $POSTGRES_INIT
}

if [ $# -ne 3 ]
then
  echo "Wrong number of arguments"
  exit 1
fi

cleanup_database ${ALF_DB} ${ALF_USER}

echo "Deleting directory"
sudo rm -rf ${INSTALL_DIR}
