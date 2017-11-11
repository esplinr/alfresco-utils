#!/bin/sh
# A Linux startup script for Alfresco Community Edition.
# Tested on CentOS 7.4 and Fedora 26
# 
# Put in /etc/rc.d/init.d/alfresco
# And run:
#    systemctl enable alfresco
#    systemctl start alfresco
#
# chkconfig: 2345 80 30 
# description: Alfresco Community

RETVAL=0

# Run as user alfresco
function su_user {
  CMD=$1
  sudo su - alfresco -c "${CMD}"
}


start () {
    su_user "/opt/alfresco-community/alfresco.sh start \"$2\""
    RETVAL=$?
    if [ -d "/var/lock/subsys" ] && [ `id -u` = 0 ] && [ $RETVAL -eq 0 ] ; then
        touch /var/lock/subsys/alfresco
    fi

}

stop () {
    su_user "/opt/alfresco-community/alfresco.sh stop \"$2\""

    RETVAL=$?
}


case "$1" in
    start)
        start "$@"
        ;;
    stop)
        stop "$@"
        ;;
    restart)
        stop "$@"
        start "$@"
        ;;
    *)
        su_user "/opt/alfresco-community/alfresco.sh \"$@\""
        RETVAL=$?
esac
exit $RETVAL
