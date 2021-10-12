#!/bin/bash
#display of tab content & arguments
	#arguments
	echo "first arg is ... : "$0
	echo "arg numbers ... : "$#
	echo "the arg are ... : "$*
	echo "second arg is ... : "$2
	echo 'error is ... : '$7
	echo "last return of echo code is : "$?

	#tab
	tab=('tipio' 'minecraft-serv1' 'kali' 'rpi1' 'rpi2')
	len=${#tab[*]}
	#echo${#tab[@]}
	#view tab for bash & ksh93 but not ksh88
	echo 'tab contents is : '
	for i in ${!tab[@]}; do echo ${tab[i]}; done

#search file
	#search
	echo -n 'file name : '
	read file
	if [ -e $file ]; then
		echo 'file exist'
	else
		echo "file doesn't exist, at least is not in this repertory"
	fi

	#display files list
	echo -n 'do you want to see the file list of this repertoty y/n : '
	read yesno
	if [ $yesno = "y" ] || [ $yesno = 'Y' ]; then
		echo 'files list of this repertory : '
		cd /root
		ls -la
	elif [ $yesno = 'n' ] || [ $yesno = 'N' ]; then
		echo 'ok, next'
	else
		echo 'you have to type y or n !! not' $yesno
	fi


#arithmetic
	#define range of values
	for  (( i=0; i<2; i++ )); do
		(( var=4 + $i * 4 ))
		echo $var
	done
	id_per_step=$var
	for (( i=0; i<2; i++ )); do
		(( min_step_id = 1 + $i * $id_per_step ))
		(( max_step_id = (( $i + 1 )) * $id_per_step ))
		echo $min_step_id to $max_step_id
	done

#case
	echo -n "do you want to stop ? : "
	read on
	case $on in
	y | Y | o | O | oui | OUI ) echo "take a break";;
	n | N | no | NO ) echo "write script";;
	*) echo "i don't understand you'r answer"
	esac

#while & until
	#while
	cmpt=1 #count tentative
	cm=3 # count the remaining attempts
	echo -n 'your mp test : '
	read mp
	while [ $mp != 'ubuntuTest' ] && [ $cmpt != 4 ]
	do
		echo -n 'bad mp, rest' $cm 'chances before block your account : '
		read mp
		cmpt=$(($cmpt+1))
		cm=$(($cm-1))
	done
	echo 'brute-force is forbidden in the world, you must become a white hat'

	#until
	i=1
	until [ $i -gt 20 ]; do
		echo $i'*2 = '$(($i*2))
		i=$(($i+1))
	done

#select
	select choice in 'choice1 ''choice2 ''a ''b ';do
		case $choice in
		  choice1 | choice2 ) echo "you've choose" $choice;;
		  a | b ) echo "bye";;
		  *) echo "invalid entry"
		esac
	done
