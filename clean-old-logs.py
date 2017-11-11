#!/usr/bin/python3
# -*- coding: utf-8 -*-
''' clean-old-logs.py

Clean old log files from Alfresco Community Edition

I configure Alfresco to store all log files in a single directory, but by
default Alfresco Community Edition puts log files in multiple locations so this
script is easy to modify to use a different directory, filename, or age for each
log file.

Put the script into /etc/cron.daily


Copyright 2017 Alfresco Software

This product includes software developed at
The Apache Software Foundation (http://www.apache.org/).
'''

import sys
from pathlib import Path
from datetime import datetime, timedelta


DEBUG = False

# Lookup "today" just one per run
TODAY = datetime.now().date()


age_solr = 7
stub_solr = "solr.log"
glob_solr = stub_solr+".*"
def log_date_solr(log_file_name):
    ''' For the name in log_file_name, return a date object
        solr.log.YYYY-MM-DD
    '''
    date_string = log_file_name[len(stub_solr)+1:]
    return datetime.strptime(date_string, "%Y-%m-%d").date()


age_manager = 7
stub_manager = "manager"
glob_manager = stub_manager+".*"
def log_date_manager(log_file_name):
    ''' For the name in log_file_name, return a date object
        manager.YYYY-MM-DD.log
    '''
    date_string = log_file_name[len(stub_manager)+1:-len(".log")]
    return datetime.strptime(date_string, "%Y-%m-%d").date()


age_localhost_access = 1
stub_localhost_access = "localhost_access_log"
glob_localhost_access = stub_localhost_access+"*"
def log_date_localhost_access(log_file_name):
    ''' For the name in log_file_name, return a date object
        localhost_access_logYYYY-MM-DD.txt
    '''
    date_string = log_file_name[len(stub_localhost_access):-len(".txt")]
    return datetime.strptime(date_string, "%Y-%m-%d").date()


age_localhost = 3
stub_localhost = "localhost"
glob_localhost = stub_localhost+".*"
def log_date_localhost(log_file_name):
    ''' For the name in log_file_name, return a date object
        localhost.YYYY-MM-DD.log
    '''
    date_string = log_file_name[len(stub_localhost)+1:-len(".log")]
    return datetime.strptime(date_string, "%Y-%m-%d").date()


age_hostmanager = 7
stub_hostmanager = "host-manager"
glob_hostmanager = stub_hostmanager+".*"
def log_date_hostmanager(log_file_name):
    ''' For the name in log_file_name, return a date object
        host-manager.YYYY-MM-DD.log
    '''
    date_string = log_file_name[len(stub_hostmanager)+1:-len(".log")]
    return datetime.strptime(date_string, "%Y-%m-%d").date()


age_catalina= 7
stub_catalina = "catalina"
glob_catalina = stub_catalina+".*"
def log_date_catalina(log_file_name):
    ''' For the name in log_file_name, return a date object
        catalina.YYYY-MM-DD.log
    '''
    date_string = log_file_name[len(stub_catalina)+1:-len(".log")]
    return datetime.strptime(date_string, "%Y-%m-%d").date()



def clean_logs(log_dir, age_days, glob_string, log_date_func):
    age_delta = timedelta(days = age_days)
    cutoff_date = TODAY - age_delta

    log_path = Path(log_dir)
    if not log_path.is_dir():
        raise Exception("Log directory does not exist: %s" %(log_dir))

    files = [f for f in log_path.glob(glob_string)]
    for f in files:
        try:
            file_date = log_date_func(f.name)
        except ValueError:
            file_date = TODAY
        if file_date < cutoff_date:
            if DEBUG:
                print("Deleting: %s" %(f))
            f.unlink()         
        elif DEBUG:
            print("leaving: %s, file_date: %s, cutoff_date: %s"
                  %(f, file_date, cutoff_date))


def main(arg_list): #not currently using the arg_list
    # Script-style consants so we don't have to mess with options
#    ALF_LOG_DIR="/opt/alfresco-community/tomcat/logs"
    ALF_LOG_DIR="/home/system/opt/alfresco-config/logs-sample"

    if DEBUG:
        print("Log directory: %s" %(ALF_LOG_DIR))

    clean_logs(ALF_LOG_DIR, age_catalina, glob_catalina, log_date_catalina)
    clean_logs(ALF_LOG_DIR, age_hostmanager, glob_hostmanager,
               log_date_hostmanager)
    clean_logs(ALF_LOG_DIR, age_localhost, glob_localhost, log_date_localhost)
    clean_logs(ALF_LOG_DIR, age_localhost_access, glob_localhost_access,
               log_date_localhost_access)
    clean_logs(ALF_LOG_DIR, age_manager, glob_manager, log_date_manager)
    clean_logs(ALF_LOG_DIR, age_solr, glob_solr, log_date_solr)



if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))


# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
