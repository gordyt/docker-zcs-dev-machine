#!/bin/bash

DEBUGOPTS='-Xdebug -agentlib:jdwp=transport=dt_socket,address=9999,server=y,suspend=n'
mailboxd_java_options=`sudo -i -u zimbra /opt/zimbra/bin/zmlocalconfig mailboxd_java_options |sed 's/^mailboxd_java_options = //'`
echo "${mailboxd_java_options}"|grep Xdebug >/dev/null 2>&1
if [ $? -eq 0 ]
then
    echo "mailboxd_java_options already contains Xdebug"
    echo "mailboxd_java_options:${mailboxd_java_options}"
    exit 1
fi
echo "ORIGINAL mailboxd_java_options:${mailboxd_java_options}"
sudo -i -u zimbra /opt/zimbra/bin/zmlocalconfig -e mailboxd_java_options="${DEBUGOPTS} ${mailboxd_java_options}"
mailboxd_java_options=`sudo -i -u zimbra /opt/zimbra/bin/zmlocalconfig mailboxd_java_options |sed 's/^mailboxd_java_options = //'`
echo "NEW      mailboxd_java_options:${mailboxd_java_options}"

if [ -f  /opt/zimbra/libexec/zmmailboxdmgr -a ! -f /opt/zimbra/libexec/zmmailboxdmgr.sav ]
then
    echo "setup to ALLOW debugging on production system"

    (
        set -x
        cd /opt/zimbra/libexec/ &&
        sudo mv zmmailboxdmgr zmmailboxdmgr.sav &&
        sudo ln -s zmmailboxdmgr.unrestricted zmmailboxdmgr
    )
fi
