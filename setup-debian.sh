#!/bin/sh
apt-get install python3 python3-pyinotify python3-systemd -y
python setup.py install
touch /var/log/fail2ban.log
cp config/jail.local /etc/fail2ban/

cp files/debian-initd /etc/init.d/fail2ban
update-rc.d fail2ban defaults
service fail2ban stop

echo "Configure jail.local and start Fail2ban with service fail2ban start!"
