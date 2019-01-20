#!/bin/bash
file="/home/appuser/opstest/application.properties"
echo "suchname=`curl http://169.254.169.254/latest/meta-data/placement/availability-zone`" > $file
chown appuser:appuser $file
chmod 400 $file
chmod 700 /home/appuser
chmod 700 /home/ubuntu

