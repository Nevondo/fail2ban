#!/bin/bash

function checkInstallation {
    if ! [ -d /etc/fail2ban ]; then
        dialog --title "Fail2ban gefunden!" --yesno "Es scheint so als wäre Fail2ban schon installiert? Soll es deinstalliert und die neue Version installiert werden?" 8 40
        response=$?

        if [ $response = 0 ]; then
                apt-get purge fail2ban
                rm -R /etc/fail2ban
                rm /etc/init.d/fail2ban
                installFail2ban
            else
                echo "Installation vom Benutzer abgebrochen! Fail2ban ist schon installiert!"
                exit
            fi
fi
}

function checkDependencies {
    if ! [ "dpkg --get-selections | grep python3" ]; then
       apt-get install python3 python3-pyinotify python3-systemd -y
    fi

     if ! [ "dpkg --get-selections | grep python3-pyinotify" ]; then
       apt-get install python3-pyinotify -y
    fi

     if ! [ "dpkg --get-selections | grep python3-systemd" ]; then
       apt-get install python3-systemd -y
    fi

    if ! [ "dpkg --get-selections | grep python3-systemd" ]; then
       apt-get install python3-systemd -y
    fi
}

function installFail2ban {
    python setup.py install
    touch /var/log/fail2ban.log
    cp config/jail.local /etc/fail2ban/

    email=$(\
        dialog --title "Fail2ban E-Mail Einstellungen" \
               --inputbox "Gebe deine E-Mail ein mit der Fail2ban senden soll." 8 40 \
        3>&1 1>&2 2>&3 3>&- \
    )
    sed -i "s/%EMAIL%/$email/g" /etc/fail2ban/jail.local

    dialog --title "Fail2ban Blocklist Einstellungen" --yesno "Blocklist.de konfigurieren?" 8 40
    response=$?

    if [ $response = 0 ]; then
			blocklist=$(\
				dialog 	--title "Fail2ban E-Blocklist Einstellungen" \
						--inputbox "Gebe deinen API Key von Blocklist.de ein." 8 40 \
				3>&1 1>&2 2>&3 3>&- \
			)
			sed -i "s/%BLOCKLISTKEY%/$blocklist/g" /etc/fail2ban/jail.local
			sed -i 's/%ACTION%/action_blocklist_de/g' /etc/fail2ban/jail.local
        else
		sed -i 's/%ACTION%/action_/g' /etc/fail2ban/jail.local
    fi

cp files/debian-initd /etc/init.d/fail2ban
update-rc.d fail2ban defaults
service fail2ban restart
}

dialog="dpkg --get-selections | grep dialog"
if ! [ $dialog == "" ]; then
    apt-get install dialog
fi

checkInstallation
checkDependencies
installFail2ban
echo "Fail2ban wurde erfolgreich installiert!"
sleep 5

