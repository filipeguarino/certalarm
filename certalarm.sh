#! /usr/bin/env bash
# script that notify when cert will expire

export $(cat expiration.txt) 1> /dev/null 2> /dev/null

# functions definitions

FuncReq() {
	rpm -qa|grep -oE mutt 1> /dev/null 2> /dev/null
	if [ $? = 0 ]; then
	    echo "mutt installed" 1> /dev/null 2> /dev/null
        else
	    yum -y install mutt 1> /dev/null 2> /dev/null
            cat mutt.cfg > ~/.muttrc
        fi
}

FuncMailNotif() {
	if [ $DAYS_TO_EXPIRE -ge 90 ]; then
		echo "DAYS_TO_EXPIRE=$(($DAYS_TO_EXPIRE -1))" > expiration.txt
		exit 0
	fi
	local EXPIRED=0
	if [ $DAYS_TO_EXPIRE -ge $EXPIRED ]; then
	    echo "send mail"
	    echo "DAYS_TO_EXPIRE=$(($DAYS_TO_EXPIRE -1))" > expiration.txt
	    for MAILADDR in $(cat mailto.txt); do
	        echo "[CERT_ALARM] the certificate will expire in $DAYS_TO_EXPIRE days" | mutt -s "[CERT_ALARM] Warning! Certificate will expire soon!!" -- $MAILADDR
    	        echo "[$(date +%d%m%Y)] [CERT_ALARM] mail sent to $MAILADDR" >> /var/log/messages
    	        sleep 3
            done
            echo "[$(date +%d%m%Y_%H%M)] [CERT_ALARM] the certificate will expire in $DAYS_TO_EXPIRE days" >> /var/log/messages	
	fi
}

# call functions

FuncReq
FuncMailNotif
