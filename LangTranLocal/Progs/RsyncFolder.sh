#!dash 
#
# RsyncFolder.sh
#
# To sync a folder tree from the server to this computer.
# It will make a path to the folder if necessary.
#
# WARNING!!! This is a cygwin script (ie Unix/Linux commands for Windows)
#		It will be executed by the shell called "dash",
#		so each line must end with the Unix standard,
#		just a newline character,
#		not the Windows standard of <CR><LF>.
#		So it needs to be edited with a programmer's editor,
#		not with Notepad.
#
# echo I am $0.
# echo arg 1 is $1
# echo No. of args is $#
# echo LTserver is $LTserver
# echo FolderCount is $FolderCount
echo $0 here. Timeout variable is $Tmo
Delay=15    # time to wait between attempts to rsync, if being Persistent
ShortDest=Win_main

if [ -r Progs/$FolderCount ]
then
    FOLDERSUPDATED=`sed -n "s/[^0-9]*\([0-9]*\)[^0-9]*/\1/p" \
	Progs/$FolderCount`
else
    echo where is Progs/$FolderCount \?
fi

# echo dash script here, FOLDERSUPDATED is $FOLDERSUPDATED
# PATH=./$ShortDest/$SyncFolder/Sync:./Progs
echo PATH is $PATH
echo "\n"
echo "I'm updating the Group \"$1\""

# If the folder to update looks like Win_everything_en/Literacy_win
#    make sure the base directory exists, with the desired name.
# 	 (The script MkBaseDir resets the BaseDir variable.)

case "$1" in
    Win_everything_en/*)
        # echo Folder is $1.
        BaseDir=$ShortDest
        LeafDir=${1##*/}
        # echo BaseDir is $BaseDir
        # echo LeafDir is $LeafDir
        Dest=$BaseDir/$LeafDir
        ;;
    Win_everything_en)
        Dest=$ShortDest
        ;;
    *)
        Dest="$1"
        ;;
esac

echo "Destination is \"$Dest\""

if [ -d "$Dest" ]
then
    # echo "The destination folder \"$Dest\" exists already."
    true	# a no-op
else
    if mkdir -p $Dest 
    then
        echo "I just made the destination folder \"$Dest\"."
    else
        echo "I was not able to create a folder \"$Dest\"" >&2
        echo "Please investigate." >&2
        exit 2
    fi
fi

Attempts=5

while test "$Attempts" -gt 0
do
    echo Updating files from the LangTran server with the command:
    echo rsync -dvrLtuP --modify-window=1 --chmod=a=rwx --delete-delay --timeout=$Tmo --partial-dir=.rsync-bit -f "- .[Ss]ync*" "$LTserver::ltuser/$1/" "$Dest/"
    echo "\n"
    echo It can take a long time to work out what to update and get started.
    echo Please be patient :-\)
    echo "\n"

    rsync -dvrLtuP --modify-window=1 --chmod=a=rwx --delete-delay --timeout=$Tmo --partial-dir=.rsync-bit -f "- .[Ss]ync*" "$LTserver::ltuser/$1/" "$Dest/"
    RsyncErrNo=$?
    echo Return value from rsync is $RsyncErrNo
    
    case "$RsyncErrNo" in
        0)
            echo Finished updating network files in the folder "$1" 
            echo to your local computer.
            # echo "\n"
            FOLDERSUPDATED=$(($FOLDERSUPDATED+1))
            # echo FOLDERSUPDATED is $FOLDERSUPDATED

            if [ $FOLDERSUPDATED -gt 1 ] 
            then
                Pl=s
            else
                Pl=
            fi

            echo "I updated $FOLDERSUPDATED folder tree$Pl." > Progs/$FolderCount
            exit 0 ;;
        [1-4])
            echo "The rsync command was used incorrectly. See the output messages."
            exit 8 ;;
        20)
            echo "Someone interrupted the rsync program. See the messages."
            exit 20 ;;
        *)
            echo "Something went wrong updating the LangTran files to your computer."
            Attempts=$(($Attempts-1))
            
            if test "$Attempts" -eq 0 || test "$Persistent" = no
            then
                echo "Giving up now."
                exit 4
            else
                if [ "$Attempts" -gt 1 ] 
                then
                    Pl="times"
                else
                    Pl="more time"
                fi

                echo "I'll try again $Attempts $Pl, starting again in $Delay seconds."
                sleep $Delay
            fi
            ;;
    esac
done

