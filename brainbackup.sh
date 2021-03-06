#!/bin/bash
############  script written by Christophe Casalegno and made available for use, rewrite and adapt as needed in 21  ############

CONFIG_FILE="brainbackup.cfg"
ROUTESCRIPT=$(grep -w "ROUTESCRIPT" "$CONFIG_FILE" |cut -d ":" -f2)


############  variables  ############
# databases (MySQL / MariaBD)
MYSQL_BACKUP_USER=$(grep -w "MYSQL_BACKUP_USER" "$CONFIG_FILE" |cut -d ":" -f2)
MYSQL_USER_PASS=$(grep -w "MYSQL_USER_PASS" "$CONFIG_FILE" |cut -d ":" -f2)
MYSQL_LOCAL_ROUTE=$(grep -w "MYSQL_LOCAL_ROUTE" "$CONFIG_FILE" |cut -d ":" -f2)
MYSQL_LOCAL_RETENTION=$(grep -w "MYSQL_LOCAL_RETENTION" "$CONFIG_FILE" |cut -d ":" -f2)
MYSQL_DB_LIST=$(grep -w "MYSQL_DB_LIST" "$CONFIG_FILE" |cut -d ":" -f2)

# files and directories
BACKUP_DIREC_LIST=$(grep -w "BACKUP_DIREC_LIST" "$CONFIG_FILE" |cut -d ":" -f2)
BACKUP_SERVER_NAME=$(grep -w "BACKUP_SERVER_NAME" "$CONFIG_FILE" |cut -d ":" -f2)
BACKUP_SERVER_ROUTE=$(grep -w "BACKUP_SERVER_ROUTE" "$CONFIG_FILE" |cut -d ":" -f2)
BACKUP_SERVER_DST=$(grep -w "BACKUP_SERVER_DST" "$CONFIG_FILE" |cut -d ":" -f2)
DIR_REMOTE_RETENTION=$(grep -w "DIR_REMOTE_RETENTION" "$CONFIG_FILE" |cut -d ":" -f2)

#BACKUP_COMMAND='rsync'
BACKUP_COMMAND='rdiff-backup'

############  functions  ############
# databases (MySQL / MariaBD)
function mysql_local_backup_dir ()
{
        MYSQL_LOCAL_ROUTE="$1"
        MY_DATE=$(date +"%Y-%m-%d:%H-%M")

        if [ ! -d "$MYSQL_LOCAL_ROUTE" ]
        then
                mkdir "$MY_SQL_LOCAL_ROUTE"
        fi # test the existence of the file and create it if it does not exist

        mkdir "$MYSQL_LOCAL_ROUTE"/"$MY_DATE" # create sub directories
        mkdir "$MYSQL_LOCAL_ROUTE"/"$MY_DATE"/logs # create sub directories
} # creation of the local backup directory

function mysql_backup_list ()
{
        MYSQL_LOCAL_ROUTE="$1"
        MYSQL_DB_LIST="$2"

        mysqlshow -u"$MYSQL_BACKUP_USER" -p"$MYSQL_USER_PASS" |cut -d " " -f2 |grep m >/$MYSQL_LOCAL_ROUTE/$MYSQL_DB_LIST ####### have to corect correct the line to accept all characters wih "grep" option : [a-z\|A-Z\|0-9]
} # write the list of all databases to backup => exclusion ?

function mysql_backup ()
{
        COMPRESSOR="pigz"
        MY_DATE=$(date +"%Y-%m-%d:%H-%M")
        MYSQL_LOCAL_ROUTE="$1"
        MYSQL_DB_LIST="$2"
        MYSQLDUMP_OPTIONS="--dump-date --no-autocommit --single-transaction --hex-blob --triggers -R -E"
        # MYSQLDUMP_OPTIONS are are some main and practical options for a good execution (stored procedures, events, triggers, hex-lob transform bytes to hexadecimal)
        # single-transaction does not block databases in inoDB format with a lock so as not to cut production during the backup process)

        while read DB_NAME
        do
                echo "Dumping $DB_NAME..."
                mysqldump -u"$MYSQL_BACKUP_USER" -p"$MYSQL_USER_PASS" "$DB_NAME" $MYSQLDUMP_OPTIONS | "$COMPRESSOR" > $MYSQL_LOCAL_ROUTE/$MY_DATE/$DB_NAME-$MYDATE.sql.gz 2>>$MYSQL_LOCAL_ROUTE/$MY_DATE/$DB_NAME-$MYDATE-error.log
        done < /"$MYSQL_LOCAL_ROUTE"/"$MYSQL_DB_LIST" # "while read DB_NAME" takes as input the file cited here through the double chevron
} # execute the local backup for each of the databases, exclusion?

function mysql_purge_old_backup ()
{
        MYSQL_LOCAL_ROUTE="$1"
        MYSQL_LOCAL_RETENTION="$2"

        if [ ! -d "MYSQL_LOCAL_ROUTE" ]
        then
                exit 0 # test if the road exists : very careful here because we are going to delete files, so especially not to assign this function to all the server is necessary !
        else
                find "$MYSQL_LOCAL_ROUTE" -mtime +"MYSQL_LOCAL_RETENTION" -exec rm -rf {} \;
        fi # date exec or |xargs # find search in local route and delete depending the retentiion
} # purge old local MariaDB/MySQL backups

function do_mysql_backup ()
{
        MYSQL_LOCAL_ROUTE="$1"
        MYSQL_DB_LIST="$2"
        MYSQL_LOCAL_RETENTION="$3"

        mysql_local_backup_dir $MYSQL_LOCAL_ROUTE
        mysql_backup_list $MYSQL_LOCAL_ROUTE $MYSQL_DB_LIST
        mysql_backup $MYSQL_LOCAL_ROUTE $MYSQL_DB_LIST
        #mysql_purge_old_backup $MYSQL_LOCAL_ROUTE $MYSQL_LOCAL_RETENTION
} # execute the complete process integrating the other functions

do_mysql_backup $MYSQL_LOCAL_ROUTE $MYSQL_DB_LIST $MYSQL_LOCAL_RETENTION

#files and directories:
function dir_backup_list ()
{
        ROUTESCRIPT="$1"
        BACKUP_DIREC_LIST="$2"

        ls -d -- /*/ |grep -v -w "bin\|boot\|etc\|lib\|media\|mnt\|opt\|proc\|root\|run\|sbin\|srv\|sys\|tmp\|usr\|var\|dev" |cut -d "/" -f2 >/"$ROUTESCRIPT"/"$BACKUP_DIREC_LIST" # ls -d -- /*/ |grep -v -w "media\|mnt\|proc\|sys\|dev" |cut -d "/" -f2 >/"$ROUTESCRIPT"/"$BACKUP_DIR_LIST"
} # write the list of all files and directories to backup

function dir_remote_backup ()
{
        BACKUP_SERVER_DST="$1"
        BACKUP_SERVER_NAME="$2"
        BACKUP_SERVER_ROUTE="$3"
        BACKUP_DIREC_LIST="$4"
        BACKUP_COMMAND="$5"

        while read dir2backup
        do
                echo "Backuping $dir2backup..."
                $BACKUP_COMMAND /"$dir2backup" "$BACKUP_SERVER-DST"@"$BACKUP_SERVER_NAME"::"$BACKUP_SERVER_ROUTE/$BACKUP_SERVER_DST"/"$dir2backup"
        done < /"$ROUTESCRIPT"/"$BACKUP_DIREC_LIST"
} # execute the backup of the files/repertories on the backup server : rdiff-backup

function dir_remote_purge ()
{
        BACKUP_SERVER_DST="$1"
        BACKUP_SERVER_NAME="$2"
        BACKUP_SERVER_ROUTE="$3"
        BACKUP_DIR_LIST="$4"
        DIR_REMOTE_RETENTION="$5"
        BACKUP_COMMAND="$6"
        PURGE_OPTIONS="--force --remove-older-than"

        while read dir2backup
        do
                echo "Cleaning $dir2backup..."
                $BACKUP_COMMAND "$PURGE_OPTIONS" "$DIR_REMOTE_RETENTION"D "$BACKUP_SERVER_DST"@"$BACKUP_SERVER_NAME"::/"$BACKUP_SERVER_ROUTE/$BACKUP_SERVER_DST"/"$dir2backup"
        done < /"$ROUTESCRIPT"/"BACKUP_DIREC_LIST"
} # purge old backups depending on the retention : rdiff-backup ### needs to be adjusted with purge_option and "D"

function do_dir_backup ()
{
        ROUTESCRIPT="$1"
        BACKUP_DIREC_LIST="$2"
        BACKUP_SERVER_DST="$3"
        BACKUP_SERVER_NAME="$4"
        BACKUP_SERVER_ROUTE="$5"
        BACKUP_COMMAND="$6"
        DIR_REMOTE_RETENTION="$7"

        dir_backup_list "$ROUTESCRIPT" "$BACKUP_DIREC_LIST"
        dir_remote_backup "$BACKUP_SERVER_DST" "$BACKUP_SERVER_NAME" "$BACKUP_SERVER_ROUTE" "$BACKUP_DIREC_LIST" "$BACKUP_COMMAND"
        #dir_remote_purge "$BACKUP_SERVER_DST" "$BACKUP_SERVER_NAME" "$BACKUP_SERVER_ROUTE" "$BACKUP_DIREC_LIST" "$DIR_REMOTE_RETENTION" "$BACKUP_COMMAND"
} # groups together the differents tasks to be performed for the backup of files

do_dir_backup "$ROUTESCRIPT" "$BACKUP_DIREC_LIST" "$BACKUP_SERVER_DST" "$BACKUP_SERVER_NAME" "$BACKUP_SERVER_ROUTE" "$BACKUP_COMMAND" "$BACKUP_REMOTE_RETENTION"