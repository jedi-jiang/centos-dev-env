#!/bin/bash
#disable the SELinux
/usr/sbin/setenforce 0
/usr/bin/supervisord -n -c /etc/supervisord.conf
