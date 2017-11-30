#!/bin/bash
# Install Alfresco
# install-alfresco.sh [DB_NAME] [DB_USER] [DB_PASS] [ALF-DIR] [INSTALLER] [INSTALL_OPTS] [OS_USER]

ALF_DB=$1
ALF_USER=$2
DB_PASS=$3
INSTALL_DIR=$4
ALF_INSTALLER=$5
INSTALLER_OPTS=$6
OS_USER=$7


PGHBA_PATH="/var/lib/pgsql/data/pg_hba.conf"
POSTGRES_INIT="postgresql.service"


# Some commands need to be run as another user
function su_user {
  USER=$1
  CMD=$2
  sudo su - ${1} -c "${CMD}"
}

function run_psql_cmd {
  CMD=$1
  su_user postgres "psql -c \"${CMD}\""
}
function check_psql {
  CMD=$1
  CHECK_STRING=$2
  run_psql_cmd "${CMD}" | grep " ${CHECK_STRING} "
}


function setup_database_user {
  ALF_DB=$1
  ALF_DB_PASS=$2
  if ! check_psql "\\du" ${ALF_USER}; then
    echo "Creating user"
    su_user postgres "createuser -S -D -R ${ALF_USER}"
    run_psql_cmd "alter user ${ALF_USER} with password '${ALF_DB_PASS}';"
  else
    echo "Database user exists"
  fi
}

function setup_database_db {
  ALF_DB=$1
  createdb=false
  if ! check_psql "\\l" ${ALF_DB}; then
    echo "Creating database"
    su_user postgres "createdb ${ALF_DB} -O ${ALF_DB}"
    createdb=true
  else
    echo "Database exists"
  fi
  if $createdb; then
    return 0 # 0=true--db was created
  else
    return 1
  fi
}

function setup_pghba {
  ALF_DB=$1
  ALF_USER=$2
  if ! su_user postgres "grep \" ${ALF_DB} \" ${PGHBA_PATH}"; then
    echo "Adding to pg_hba.conf"
    # I can't get this to only affect the first occurance, so watch out for
    # multiple markers in the file.
    # Order matters, so it has to be above the default config
    sudo sed -i "/# TYPE  DATABASE        USER            ADDRESS                 METHOD/a \
local  ${ALF_DB}    ${ALF_USER}                   md5 \\
host   ${ALF_DB}    ${ALF_USER}     127.0.0.1/32  md5 "\
      ${PGHBA_PATH}
    sudo systemctl reload $POSTGRES_INIT
  else
    echo "pg_hba.conf already has ${ALF_DB} info"
  fi
}

function setup_database {
  ALF_DB=$1
  ALF_USER=$2
  DB_PASS=$3
  echo "Setting up Database . . ."
  setup_pghba ${ALF_DB} ${ALF_USER}
  setup_database_user ${ALF_USER} ${DB_PASS}
  if setup_database_db ${ALF_DB} ${ALF_USER}; then
    return 0 # 0=true--db was created
  else
    return 1
  fi
}


setup_database ${ALF_DB} ${ALF_USER} ${DB_PASS}

# Create directory
sudo mkdir ${INSTALL_DIR}
sudo chown -R ${OS_USER} ${INSTALL_DIR}

# Run installer as alfresco user with options file
echo "Running the installer . . ."
su_user ${OS_USER} "${ALF_INSTALLER} --optionfile ${INSTALLER_OPTS}"
