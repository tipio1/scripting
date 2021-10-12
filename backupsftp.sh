#! /bin/bash

#display an help for user 
if [[ "$1" == 'help' ]]
then
	echo 'using name script and pass to execute'
	exit 0
fi

if [[ $# -ne 3 ]]
then
	echo 'all options are not included correctly'
	exit 20
fi

#variables
sftp_pass=$1
sftp_user='pi'
sftp_host_ip=$2
sftp_file2copy=$3
sftp_dir2copy='/data/nas'

#ping the host
if [[ $(sudo ping -c 1 -W 1 $sftp_host_ip | grep -c "time") -eq 0 ]]
then
	echo '$sftp_host_ip do not answer'
	exit 21
fi

#search if the file or folder to backup exist and run backup
if [[ -f $sftp_file2copy ]] 
then
#sricpt execution
	sshpass -p $sftp_pass sftp $sftp_user@$sftp_host_ip << ENDSFTP
	cd /home/tipio/bin
	put $sftp_file2copy $sftp_dir2copy
	exit
ENDSFTP
else
	echo "this file does nit exit"
fi
