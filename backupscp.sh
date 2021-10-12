#!/bin/bash

host_ip='192.168.2.5' 
scp_user='pi'
# if using special ssh port : scp_port='$3'
#file2copy='/home/tipio/bin/test.txt'
dir2copy='/data/nas' 
# if using relay : scp_realy='$5'


function scpcopy(){
	#host_ip='$1'
	#scp_user='$2'
	# if using special ssh port : scp_port='$3'
	#file2copy='$3'
	#dir2copy='$4'
	# if using relay : scp_realy='$5'

	#scp -oPort=$scp_port "$file2copy" "$scp_user"@"$host_ip":"$dir2copy"
	scp "$line" "$scp_user"@"$host_ip":"$dir2copy"
}

# be carrefull in bash language, functions must be call after she is declared, else bash doesn't understand

for line in $(cat /home/tipio/bin/backup_list.txt)
do
	scpcopy "$host_ip" "$scp_user" "$line" "$dir2copy"
done

