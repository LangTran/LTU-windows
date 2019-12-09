#!dash
# PruneArchive.sh -- Almost the same version
# for Linux, Mac and Windows cygwin dash
# Version 3.05, last edited 2019-08-28 at 17:19
# arguments: number-to-keep

# In this version, the caller, LangTranUpdate, must 
# pushd to the folder to prune, 
#     call this script and then 
# popd back again to the original folder.
#
platform=Windows

# Note: dash uses a built-in "echo", which interprets \n etc as escape sequences,
#       so Windows paths come out changed if the first letter of a foldername
#       begins with n ot b or c or f or v and some others.
#       So we use printf "%s\n" "$variable" instead of using echo.
#
MYNAME="$0"
# verbosity of 7 is a good number for checking progress.
verbose=0

[ $verbose -ge 8 ] && printf "My name is %s\n" "$MYNAME"
[ $verbose -ge 8 ] && echo My PID is $$ and PPID is $PPID

# Set behaviour for bash or dash shell running this script.
#
case "$platform" in
    Linux)
        if [ $verbose -ge 8 ] 
        then
            echo Dollar dollar is $$
            echo ps -f shows
            ps -f
            echo This should show the name of the shell:
            ps -f -p $$ | sed -nr -e "/$$/p"
        fi

        ShellLine=$(ps -f -p $$ | sed -nr -e "/$$/p")
    ;;
    Windows)
        ShellLine=$(ps -p $$ | sed -nr -e "/$$/p")
    ;;
esac

case "$ShellLine" in
    *bash)
        MyShell=bash
        Eq="=="
        ;;
    *dash)  # Cygwin dash is much smaller than bash,
            # so that's what we supply for the Windows version.
        MyShell=dash
        Eq="="
        
        # We don't supply cat.exe for the Windows version,
        # so here is a function to do the simple cat job.
        cat ()
        {
            sed '/1,$/p' "$@"
        }
        ;;
    *)
        echo It seems the shell is neither bash nor dash.
        Eq="="
        MyShell=unknown
        ;;
esac

if [ $verbose -ge 8 ]
then
    echo MyShell is $MyShell
    echo Eq is $Eq
fi

[ $verbose -ge 8 ] && printf "TEMP is %s\n" "\"$TEMP\""
[ "$TEMP" $Eq "" ] && TEMP=/tmp
[ $verbose -ge 8 ] && printf "TEMP is %s\n" "\"$TEMP\""

[ $verbose -ge 8 ] && printf "PATH is %s\n" "$PATH"

# Looking for folders containing Test
#
# pwd | sed -n "/Test/p" >> "$TEMP/LTU-TestHits.txt"

# Prune archive in named folder to N items
# Windows version receives only 1 argument, number of versions to keep.
#
if [ "$1" $Eq "" ] 
then
    printf "%s\n" "$MYNAME: Incorrect arguments." >&2
    printf "Usage: %s NumberOfItemsToKeep\n" "$MYNAME" >&2
    exit 1
    # checked OK 2016-03-26
fi

KeepArchNr="$1"
# Folder=$(cygpath "$2" | sed -r -e 's/\r//' -e 's#^([A-Z]):#/cygdrive/\L&#')
# Folder=$(cygpath "$2" | sed -r "s#^([A-Z])#\L&#" | 
  #  sed -r "s#^([a-z]):#/cygdrive/\1#")

# set -x
# Folder=$(printf "%s\n" "$2" | sed -r -e 's#\\#/#g' -e 's/"//g' -e "s/'/\\\'/g" \
#         -e 's#^([A-Z])#\L&#' \
#         -e 's#^([a-z])\:#/cygdrive/\1#')

case "$platform" in
    Linux)
        Folder=$(echo "$2" | sed -r -e 's/"//g' -e "s/'/\\\'/g")
        PathToReport="$2"
        ;;
    Windows)
        Folder=$(pwd | sed -r -e 's#\\#/#g' -e 's/"//g' -e "s/'/\\\'/g" \
            -e 's#^([A-Z])#\L&#' \
            -e 's#^([a-z])\:#/cygdrive/\1#')
        
        # cpFolder=$(cygpath "$2")
        cpFolder=$(cygpath "$PWD")
        PathToReport="$PWD"
        ;;
esac

# set +x

if [ $verbose -ge 9 ] && [ "$platform" $Eq "Windows" ]
then
    if [ "$cpFolder" != "$Folder" ]
    then
        echo "DIFFERENT FOLDER VARIABLES, cygpath version then sed version:"
        echo $cpFolder
        printf "%s\n" "$Folder"
        echo " "
        read -r -p "Press the Enter key to continue... " key < /dev/tty # pause
    fi

    printf "Folder is %s\n" "$Folder"
    printf "Path2report is %s\n" "$PathToReport"
    echo " "
    echo cygpath says:
    cygpath "$PWD" | sed -r "s#^([A-Z])#\L&#" | sed -r "s#^([a-z]):#/cygdrive/\1#"
    cygpath "$PWD" | sed -r "s#^([A-Z]):#/cygdrive/\L&#"
    read -r -p "Press the Enter key to continue... " key < /dev/tty # pause


fi

# Define functions
#
FileSize ()
{
    ls -og "$1" | sed -r "s/([^ ]+) ([^ ]+) +([0-9]+) .*/\3/"
}

RemoveAny ()
{
    while read line
    do
        printf "%s  deleted\n" "\"$line\""
        printf "    from %s . . . \n" "\"$PathToReport\""
        unlink "$line"
    done

    if [ $verbose -ge 6 ]
    then
	read -r -p "Press the Enter key to continue... " key < /dev/tty # pause
    fi
}

if [ $verbose -ge 6 ]
then
    printf "KeepArchNr is $KeepArchNr and Folder is %s\n" "\"$Folder\""
fi

# ls -t | sed "s/'/\\\'/" > ${TEMP}/LTU-files.txt
ls -t > ${TEMP}/LTU-files.txt

if [ `FileSize "${TEMP}/LTU-files.txt"` $Eq 0 ]
then
    exit 0
fi

if [ $verbose -ge 9 ]
then
    echo " "
    echo LTU-files.txt contains
    cat ${TEMP}/LTU-files.txt
    read -r -p "Press the Enter key to continue... " key < /dev/tty # DOS pause
fi

sed -n "/[0-9]/p" ${TEMP}/LTU-files.txt > ${TEMP}/LTU-numhits.txt 2>&1

[ `FileSize "${TEMP}/LTU-numhits.txt"` $Eq 0 ] && exit 0

if [ $verbose -ge 8 ]
then
    echo " "
    echo LTU-numhits.txt contains
    cat ${TEMP}/LTU-numhits.txt
    read -r -p "Press the Enter key to continue... " key < /dev/tty # DOS pause
fi

# Now to get the patterns for the plain files in this folder.
#
# Protect characters used in regular expressions
# Protect filename extensions and [_.-] not adjacent to digits
# Replace [0-9_.-] with sed patterns
# Reinstate [_.-]

[ $verbose -ge 7 ] && echo About to make patterns0

# /:qt:/ for quote
# /:lp:/ for left parenthesis
# /:rp:/ for right parenthesis
# /:plus:/ for +
# /:dlr:/ for dollar
# /:dot:/ for dot
# /:ub:/ for underbar
# /:dash:/ for dash
# /:dig:/ for digits, dot, underbar or dash
sed -r -e "/^\.Sync/d" < ${TEMP}/LTU-numhits.txt \
        -e "s#'#/:qt:/#g" \
        -e "s#\\\\##g" \
        -e "s#\\(#/:lp:/#g" \
        -e "s#\\)#/:rp:/#g" \
        -e "s#\\+#/:plus:/#g" \
        -e 's#\$#/:do:/#g' \
        -e "s#\.([^_\.0-9-])#/:dot:/\1#g" \
        -e "s#([^_\.0-9-])?_([^_\.0-9-])#\1/:ub:/\2#g" \
        -e "s#([^_\.0-9-])-([^_\.0-9-])#\1/:dash:/\2#g" \
        -e "s#([^_\.0-9-])\.([^_\.0-9-])#\1/:dot:/\2#g" \
        -e "s#([0-9\._-]+)#/:dig:/#g" |
        sort|uniq > ${TEMP}/LTU-patterns0.txt
set +x
if [ `FileSize "${TEMP}/LTU-patterns0.txt"` $Eq 0 ]
then
    echo "nothing in \${TEMP}/LTU-patterns0.txt, so quitting this folder now." >&2
    exit 0
fi

if [ $verbose -ge 8 ]
then
    echo " "
    echo LTU-patterns0.txt contains
    cat ${TEMP}/LTU-patterns0.txt
    read -r -p "Press the Enter key to continue... " key < /dev/tty # DOS pause
fi

[ $verbose -ge 7 ] && echo About to make patterns

# Protect + and parens from filenames
# then replace * with version number pattern
# then /// with _ etc.
#

# /:qt:/ for quote
# /:lp:/ for left parenthesis
# /:rp:/ for right parenthesis
# /:plus:/ for +
# /:dlr:/ for dollar
# /:dot:/ for dot
# /:ub:/ for underbar
# /:dash:/ for dash
# /:dig:/ for digits, dot, underbar or dash

sed -r  -e "s#/:dig:/#[0-9_\\.-]+#g" < ${TEMP}/LTU-patterns0.txt \
    -e "s#/:ub:/#_#g" \
        -e "s#/:dash:/#-#g" \
        -e 's#/:dlr:/#\\\\$#g' \
        -e 's#/:lp:/#\\\\(#g' \
        -e 's#/:rp:/#\\\\)#g' \
        -e 's#/:plus:/#\\\\+#g' \
        -e "s#/:qt:/#'#g" \
        -e 's#/:dot:/#\\\\.#g' |
    sort|uniq |
    sed "s/\r//" > ${TEMP}/LTU-patterns.txt
    
# Check for patterns containing a single quote (ie. apostrophe)
# Don't think we need this any more.
# cat ${TEMP}/LTU-patterns.txt |
#     sed -nr "s/(.*'.*)/WARNING: single quote in pattern \1\r\n/p" 

if [ $verbose -ge 7 ]
then
    echo " "
    echo LTU-patterns.txt contains
    cat ${TEMP}/LTU-patterns.txt
    read -r -p "Press the Enter key to continue... " key < /dev/tty # DOS pause
fi

# for each pattern in ${TEMP}/LTU-patterns.txt
#     remove installers older than number $KeepArchNr
#
cat ${TEMP}/LTU-patterns.txt |
    while read line
    do
        if [ $verbose -ge 8 ]
        then
            echo " "
            printf "pattern is %s\n" "\"$line\""
        fi

        [ $verbose -ge 5 ] && set -x
        
        sed -nr "/^${line}$/p" < ${TEMP}/LTU-numhits.txt > ${TEMP}/LTU-hits.txt

        [ $verbose -ge 5 ] && set +x

        if [ $verbose -ge 5 ]
        then
            if [ `FileSize "${TEMP}/LTU-hits.txt"` $Eq 0 ]
            then
                echo No hits. It seems sed is not matching pattern properly.
                echo in folder $PathToReport
                printf "pattern: %s\n" "$line"
                read -r -p "Press the Enter key to continue... " key \
                    < /dev/tty # DOS pause
            else
                if [ $verbose -ge 7 ]
                then
                    echo " "
                    echo LTU-hits.txt contains
                    cat ${TEMP}/LTU-hits.txt
                    echo " "
                fi
            fi
        fi
        
        sed "1,${KeepArchNr}d" ${TEMP}/LTU-hits.txt | RemoveAny
    done

# fallthrough

exit 0
