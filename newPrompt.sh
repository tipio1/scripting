#!/bin/bash
clear
#for
	#1_example of syntax
	#for (( i=$min; i<=$max; i++ )); do
    	#	instructions_with_i # or not
	#done

	#2
	i=1
	for var in *; do
    		echo $i'.'$var
		i=$(($i+1))
	done

#function
#Definition of our function
display_files(){
	echo 'list all files in this repertoty'
	for var in *.txt; do
        	echo "$var"
        done
  	ls -la
}
#end of the function définition

echo "you'll see all files of this repertory : "
display_files #call our function

#new prompt
echo
echo "#################### newPrompt script ############################"
echo
echo "#############################"
echo -n "login with user name : "
read login
echo -n "login with host name : "
read host
echo "#############################"
echo
echo "### for known commands type help ###"
echo
while [ 1 ]; do                                 # allows an infinite loop
#echo -n $login'@'$host'$'                      # which ends with break
echo -e '\033[0;37;40m'┌──#'\033[1;34;40m'$login'\033[1;34;40m'@'\033[1;34;40m'$host'\033[0m'
echo -n
read reps

case $reps in
  help | hlp )
     echo "about --> this script"
     echo "ls --> repertory files list"
     echo "rm --> remove a file (guided)"
     echo "rmd --> delete a folder (guided)"
     echo "kernel --> kernel linux version"
	echo "quit --> exit"
     echo "connect --> who will be connect recently";;
  ls )
     ls -la;;
  rm )
     echo -n "Quel fichier voulez-vous effacer : "
     read eff
     rm -f $eff;;
  rmd | rmdir )
     echo -n "Quel répertoire voulez-vous effacer : "
     read eff
     rm -r $eff;;
  kernel | "uname -r" )
     uname -r;;
  connect )
     last;;
  about | --v | vers )
     echo "Script simple pour l'initiation aux scripts shell";;
  quit | "exit" )
     echo bye!!
     break;;
  * )
    echo "Commande inconnue";;
esac
done
