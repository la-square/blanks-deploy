#!/usr/bin/env bash

#Script create basic settings of uwsgi service

#Script takes a value: app_name

#Example:
#uwsgi-basic-config.sh

#Require:
#installed python-uwsgi -n project_name

#----------------------------------------------------------------------------
#Check options

while [[ $# -gt 1 ]]
do
    key="$1"
    case $key in
        -n|--name)
        APP_NAME=$2
        shift ;;
    esac
    shift
done

if [[ $APP_NAME = "" ]]; then
    echo "ERR: forgot APP_NAME attr."
    exit 1
fi


#----------------------------------------------------------------------------
#Prepair uwsgi comfig

mkdir -p /etc/uwsgi/applications
rm -rf /etc/uwsgi/main_uwsgi.ini

touch /etc/uwsgi/main_uwsgi.ini
cat >> /etc/uwsgi/main_uwsgi.ini << EOF
[uwsgi]
main_uwsgi = /etc/uwsgi/applications
uid = hotdog
gid = hotdog
master = true
enable-threads = true

EOF


#----------------------------------------------------------------------------
#Prepair uwsgi daemon

rm -rf /etc/systemd/system/uwsgi.service
mkdir /etc/systemd/system/uwsgi.service
cat >> /etc/systemd/system/uwsgi.service << EOF
[Unit]
Description=uWSGI
After=syslog.target

[Service]
ExecStart=/home/hotdog/$APP_NAME/.venv_$APP_NAME/bin/uwsgi --ini /etc/uwsgi/main_uwsgi.ini

RuntimeDirectory=uwsgi
Restart=always
KillSignal=SIGQUIT
Type=notify
StandardError=syslog
NotifyAccess=all

[Install]
WantedBy=multi-user.target

EOF