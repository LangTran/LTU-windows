@echo off
rem LangTranUpdate.cmd
rem
rem This is a comment, because it begins with "rem".
rem
rem This script will find the folders you want to update
rem from the LangTran system,
rem and for each one
rem     if there is no folder for that folder
rem         it will make it.
rem     It will then update that folder from the LangTran server.
rem
rem Version 3.01, last edited 2018-03-23 at 1444
rem This version, when pruning the archive, does pushd to the folder
rem and then calls PruneArchive.sh, then does popd back again.
rem
    echo.
    echo Don't let the black-background window startle you.
    echo I'm using it to report my progress.
    echo.
    echo This program is part of the LangTran system,
    echo and its full path and name is
    echo %0
    echo.
    echo This program copies the files in the folders that you have selected
    echo from the LangTran server onto your computer, in the current folder.

set MYNAME=%0
set LTserver=63.142.243.28
set SyncFolder=Basis_win
rem Now set SyncDir variable for 32-bit or 64-bit machine.
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" > Progs\RegOut.txt
find /i "x86" Progs\RegOut.txt > NUL && set SyncDir=Sync || set SyncDir=Sync64
del Progs\RegOut.txt
set LangTranList=LangTranList.txt
set FolderCount=FoldersUpdated.txt
set FirstRun=FirstRun.txt
set PATHbak=%PATH%
set PATH=%cd%\Win_main\%SyncFolder%\%SyncDir%;%cd%\Progs;%SystemRoot%\system32
 echo path is now %PATH%
rem pause
echo HOMEPATH is %HOMEPATH%.
echo and HOMEDRIVE is %HOMEDRIVE%.
if exist "%HOMEDRIVE%%HOMEPATH%\My Documents" set Docs=%HOMEDRIVE%%HOMEPATH%\My Documents
if exist "%HOMEDRIVE%%HOMEPATH%\Documents" set Docs=%HOMEDRIVE%%HOMEPATH%\Documents
echo.

rem Make sure the folders FileLists and Diffs exist.
if not exist FileLists\. mkdir FileLists
if not exist Diffs\. mkdir Diffs

rem Set the default values for variables to control behaviour.
rem
set DiffContext=1
set PruneDiffs=yes
set ShowDifferences=yes
set KeepNr=31
set Persistent=no
rem TiMeOut delay in seconds (5 minutes)
set Tmo=300
set KeepArchive=no
set ArchiveDir=..\LangTranArchive
set KeepArchNr=4

rem Get the control file, changing the values of some variables.
if exist .\Behaviour.cmd call .\Behaviour.cmd
if x%Persistent%x==xyesx echo Persistent mode is on.

:AskRun
rem First thing after installation, when the installer runs this script,
rem give the user an opportunity not to proceed.
rem
if exist Progs\%FolderCount% goto RunBefore
echo I'm running because the software installer started me.
echo If you want to do your first update now, type y otherwise type n
set Answer=1
if x%Silent%x==xyesx goto NoInitialQ
choice /D y /T 300 /M "Do you want to do the first update now? "
set Answer=%ERRORLEVEL%

rem fallthrough

:NoInitialQ

echo. > Progs\%FirstRun%
echo When you want to run this LangTran Update program another time, >> Progs\%FirstRun%
echo Double-click the icon on the desktop or in the START menu, >> Progs\%FirstRun%
echo (All Programs then LangTranUpdate group) >> Progs\%FirstRun%
echo called 'Update LangTran into the local folder' >> Progs\%FirstRun%

if %Answer%==2 goto BlankLine

:MakeList
rem Make a list of the files here before we download any.
.\Win_main\%SyncFolder%\%SyncDir%\date +%%Y%%m%%d_%%H%%M > Progs\FirstTime.txt
set /p FirstTime=<Progs\FirstTime.txt
echo FirstTime is %FirstTime%
del Progs\FirstTime.txt

echo Listing made at %FirstTime% > FileLists\LTF_%FirstTime%.txt
rem echo "@@" markers show line numbers where the files are different.>> FileLists\LTF_%FirstTime%.txt
rem echo "-" at start of line shows old version of file, or file removed.>> FileLists\LTF_%FirstTime%.txt
rem echo "+" at start of line shows new version of file.>> FileLists\LTF_%FirstTime%.txt
dir /s| sed -e '/\.$/d' -e '/File.s.[ ,0-9]*bytes/d' -e '/Dir.s.[ ,0-9]*bytes free/d' -e 's/$/\r/' >> FileLists\LTF_%FirstTime%.txt

rem fallthrough

:RunBefore
rem Now that Persistent mode is an option, the process could be running for hours.
rem If Persistent is on, we'll remember the process ID of this script in Progs\Kill_LTupdate.cmd,
rem so another job can kill this one if it goes on and on too long.
rem

rem If an earlier instance of this program is still running,
rem     kill it.
rem
if not exist Progs\Kill_LTupdate.cmd goto SavePID
call Progs\Kill_LTupdate.cmd

:SavePID
if not x%Persistent%x==xyesx goto TryConnect

echo I need to find my process ID, and this takes a while. Please be patient.
set TitleName=LangTranUpdate%time%
title %TitleName%
tasklist /v /fo csv| find "%TitleName%" > Progs\LTPIDline.txt
type Progs\LTPIDline.txt | sed -e "s/^[^,]*,//" -e "s/,.*//" > Progs\LTPID.txt
type Progs\LTPID.txt | sed "s#^#taskkill /T /F /pid #" > Progs\Kill_LTupdate.cmd
rem DelMe command from https://stackoverflow.com/questions/20329355/how-to-make-a-batch-file-delete-itself
type Progs\DelMe.txt >> Progs\Kill_LTupdate.cmd

:TryConnect
rem Trying to connect to LangTran server to get a listing of modules.
rem
rem echo.
rem echo I am running as the user "%username%".
echo.

set Attempts=5
:WhileCheckingConnection
echo Please wait while I check for a connection to the LangTran server . . .
rsync %LTserver%:: | find "LangTran Rsync Server"

if ERRORLEVEL 1 goto NoRsyncConnection
echo That's what I wanted to see.
goto RsyncConnection

:NoRsyncConnection
echo.
echo Error: it seems you don't have access to the LangTran server.
echo.
echo I'll try to see if I can find it.
echo Please note the results of this "ping" command:
ping %LTserver%
echo.
echo Please check that you are connected to the internet

if x%Persistent%x==xyesx (
    set /A Attempts -= 1
    echo Number of attempts to try: %Attempts%
    if %Attempts% gtr 0 goto WhileCheckingConnection
)

echo then run this file
echo (%0)
echo again.
goto end

:RsyncConnection
echo.
echo Updating folders into the folder:
cd
echo.
set FOLDERSUPDATED=0
echo %FOLDERSUPDATED% > Progs\%FolderCount%

echo Checking for updates to the LangTranUpdate system first . . .
dash -c "Progs/RsyncFolder.sh Win_everything_en/%SyncFolder%"

rem echo back from dash script RsyncFolder.sh, errorlevel is %ERRORLEVEL%
rem Now get the other folders:
set FOLDERSUPDATED=0
echo %FOLDERSUPDATED% > Progs\%FolderCount%

rem Now process the folders selected in the control file
rem
rem Remove comments and blank lines
type LangTranList.txt | sed -e "/^[[:space:]]*#/d" -e "s/#.*//" -e "s/^[[:space:]]*//" -e "s/[[:space:]]*$//" -e "/^$/d" -e "s/$/\r\n/" > Folders.txt
for /F "delims=?" %%d in ('type Folders.txt') do dash -c "Progs/RsyncFolder.sh '%%d'"
echo.

rem dir Progs\%FolderCount%
if exist Progs\%FolderCount% goto Report
goto NoReport

:Report
echo I have updated your computer from the LangTran server.
type Progs\%FolderCount%
echo.
@echo off
rem fallthrough
:NoReport

rem Make a list of the files here now.
rem
.\Win_main\%SyncFolder%\%SyncDir%\date +%%Y%%m%%d_%%H%%M > %TEMP%\TimeNow.txt
set /p TimeNow=<%TEMP%\TimeNow.txt
echo TimeNow is %TimeNow%
del %TEMP%\TimeNow.txt

echo Listing made at %TimeNow% > FileLists\LTF_%TimeNow%.txt
dir /s| sed -e '/\.$/d' -e '/File.s.[ ,0-9]*bytes/d' -e '/Dir.s.[ ,0-9]*bytes free/d' -e 's/$/\r/' >> FileLists\LTF_%TimeNow%.txt

rem Get the newest listing.
ls -1r FileLists/LTF*.txt | sed -n 1p > %TEMP%\NewList.txt
set /p NewList=<%TEMP%\NewList.txt
rem del %TEMP%\NewList.txt

rem and the one just before that.
ls -1r FileLists/LTF*.txt | sed -n 2p > %TEMP%\PrevList.txt
set /p PrevList=<%TEMP%\PrevList.txt
rem del %TEMP%\PrevList.txt

rem Now to compare the two lists
rem
echo I'm preparing a list of the changes made on this update -- please be patient :-)
echo "@@" markers show line numbers where the files are different.>> Diffs\diff_%TimeNow%.txt
echo "-" at start of line shows old version of file, or file removed.>> Diffs\diff_%TimeNow%.txt
echo "+" at start of line shows new version of file.>> Diffs\diff_%TimeNow%.txt
echo Unmarked lines are the context of changes.>> Diffs\diff_%TimeNow%.txt

rem Check for pruning internal system files from diff file.
rem
if x%PruneDiffs%x==xx goto DoDiff
sed -e "/diff_[_0-9]*\.txt/d" -e "/LTF_[_0-9]*\.txt/d" -e "/FoldersUpdated.txt/d" -e 's/$/\r/' %PrevList% > Progs\Prev.txt
set PrevList=Progs/Prev.txt
sed -e "/diff_[0-9_]*\.txt/d" -e "/LTF_[_0-9]*\.txt/d" -e "/FoldersUpdated.txt/d" -e 's/$/\r/' %NewList% > Progs\NewList.txt
set NewList=Progs/NewList.txt
goto DoDiff

:DoDiff
diff -U %DiffContext% -I "\<DIR\>" -I "LTPID.*\.txt" -I "Kill_LTupdate.cmd" %PrevList% %NewList% | sed 's/$/\r/' >> Diffs\diff_%TimeNow%.txt
if exist Progs\Prev.txt del Progs\Prev.txt
if exist Progs\NewList.txt del Progs\NewList.txt

if not %ShowDifferences% == yes goto PruneFileLists
echo I'm opening Diffs\diff_%TimeNow%.txt in notepad
echo so you can see the changes that happened this time.
echo When you have finished looking through the file,
echo please close notepad, and then I can continue.
if %ShowDifferences% == yes notepad Diffs\diff_%TimeNow%.txt

rem Remove FileLists files older than the latest KeepNr
:PruneFileLists
dir /a-d /b /O-D FileLists > %TEMP%\LTU-lists.txt 2>>&1
for /F "skip=%KeepNr% delims=" %%f in (%TEMP%\LTU-lists.txt) do (
    del "FileLists\%%f"
)

dir /a-d /b /O-D Diffs > %TEMP%\LTU-diffs.txt 2>>&1
for /F "skip=%KeepNr% delims=" %%d in (%TEMP%\LTU-diffs.txt) do (
    del "Diffs\%%d"
)

rem fallthrough

:CheckForArchiving
if %KeepArchive% == yes goto SaveArchive
goto end

:SaveArchive
rem echo User Documents are in %Docs%
set CYGWIN=nodosfilewarning

rem Now save the file and close the editor program.

if exist "%ArchiveDir%" goto ArchiveDirExists
mkdir "%ArchiveDir%"
if exist "%ArchiveDir%" echo Made Archive directory "%ArchiveDir%" > "%ArchiveDir%\NewArchive.txt"
if exist "%ArchiveDir%" goto ArchiveDirExists
echo Sorry, I wasn't able to make the folder "%ArchiveDir%".
echo I can't keep an expanding archive of your LangTran files.
goto end

:ArchiveDirExists

if not exist "%ArchiveDir%\NewArchive.txt" goto CopyArchiveNow
 echo Don't panic -- I'm about to copy lots of files from your LangTranLocal folder
 echo to your continuously-growing archive:
echo  %ArchiveDir%
if not x%Silent%x==xyesx pause

:CopyArchiveNow
echo.
echo Updating your local repository to your continuously-growing archive at
echo  %ArchiveDir%
echo.

rem Make a Cygwin version of ArchiveDir for use with rsync.
cygpath "%ArchiveDir%" > %TEMP%\ArchiveDirCygwin.txt
set /p ArchDirCyg=<%TEMP%\ArchiveDirCygwin.txt
echo ArchDirCyg is %ArchDirCyg%
del %TEMP%\ArchiveDirCygwin.txt

rsync.exe -bvrLtP --perms --chmod=a=rwx --timeout=300 --partial-dir=.rsync-bit -f "-! */***" -f "- /Diffs/*" -f "- /FileLists/*" ./ "%ArchDirCyg%/"
if exist "%ArchiveDir%\NewArchive.txt" del "%ArchiveDir%\NewArchive.txt"
echo.
rem fallthrough

:PruneArchive
echo Finished updating your LangTran files to "%ArchiveDir%/"
echo Now I am going to prune the archive to keep %KeepArchNr% versions of each
echo installer that has numbered versions.
echo It can take a while, so please be patient :-) . . .

rem For each folder in the tree of archived files
rem   call PruneArchive.cmd with ArchKeepNr and the folder name
rem This will prune numbered files to that number of versions.
rem
rem for /F "delims=" %%d in ('dir /ad /b /s "%ArchiveDir%"') do call PruneArchive.cmd "%KeepArchNr%" "%%d"

cd | cygpath -f - > %TEMP%\LTU-workdir.txt
set /p WorkDir=<%TEMP%\LTU-workdir.txt
rem echo WorkDir is %WorkDir%
del %TEMP%\LTU-workdir.txt

dir /ad /b /s "%ArchiveDir%" > %TEMP%\LTU-folders.txt
.\Win_main\%SyncFolder%\%SyncDir%\date > %TEMP%\LTU-cd-errors.txt

for /F "delims=?" %%d in ('type %TEMP%\LTU-folders.txt') do (
    rem echo Folder is "%%d"
    rem echo The current folder is
    rem cd
    rem echo ls -l %WorkDir%\Win_main\%SyncFolder%\%SyncDir%\dash.exe
    rem ls -l %WorkDir%\Win_main\%SyncFolder%\%SyncDir%\dash.exe
    rem echo ls -l %WorkDir%\Progs\PruneArchive.sh
    rem ls -l %WorkDir%\Progs\PruneArchive.sh

    pushd "%%d"
    rem echo Current working directory is
    rem cd
    rem pause
    rem echo path to PruneArchive script is
    rem echo %WorkDir%/Progs/PruneArchive.sh
rem @echo on
    rem echo my PATH is %PATH%
    rem echo which dash produces
    rem c:\cygwin32\bin\which dash
    rem ls -l "%WorkDir%/Progs/PruneArchive.sh"
    rem echo doing dash -c "%WorkDir%/Progs/PruneArchive.sh %KeepArchNr% '%%d'"
    rem dash -c "%WorkDir%/Progs/PruneArchive.sh %KeepArchNr% '%%d'" >> %TEMP%\LTU-output.txt 2>&1
    
    rem If a filename contains a single quote, we can't pass it to dash, so $2 no longer used
    dash -c "%WorkDir%/Progs/PruneArchive.sh %KeepArchNr%"
@echo off
    rem pause
    popd
    rem pause
)
rem echo That was run from LTU-folders.txt
rem pause
goto end

rem for /F "delims=" %%d in ('dir /ad /b /s "%ArchiveDir%"') do dash -c Progs/PruneArchive.sh %KeepArchNr% "%%d"

goto end

:BlankLine
echo.

rem fallthrough
:end
type Progs\%FirstRun%
set PATH=%PATHbak%
rem echo path is now %PATH%

if exist Progs\Kill_LTupdate.cmd del Progs\Kill_LTupdate.cmd
if not x%Silent%x==xyesx pause
