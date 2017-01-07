#!/bin/sh
apt-get install python git -y 
git clone git@gitlab.hosted4u.de:devtek/fail2ban.git
cd fail2ban
python setup.py install
touch /var/log/fail2ban.log

cp files/debian-initd /etc/init.d/fail2ban
update-rc.d fail2ban defaults
service fail2ban stop

echo "Configure jail.local and start Fail2ban with service fail2ban start!"
