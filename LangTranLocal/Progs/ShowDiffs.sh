#!dash 
#
# ShowDiffs.sh
#
# To show the differences between the previous list of files
# and the current one.
#
# It expects to find the previous file in
#	Changes/LTF_yyyymmdd_hhmm.txt
# and the current one in
#	Win_main/Basis_win/LangTranFiles.txt
#
# WARNING!!! This is a cygwin script (ie Unix/Linux commands for Windows)
#		It will be executed by the shell called "dash",
#		so each line must end with the Unix standard,
#		just a newline character,
#		not the Windows standard of <CR><LF>.
#		So it needs to be edited with a programmer's editor,
#		not with Notepad.
#
echo I am $0.
echo arg 1 is $1
echo No. of args is $#

Latest=Win_main/Basis_win/LangTranFiles.txt
echo The Latest file list is
ls -l $Latest

Previous=`ls -t Changes/LTF_[0-9]*.txt|sed -n 1p` 
echo The Previous file is $Previous
echo Here is a listing of them:
ls -l $Previous $Latest

# Now to make the diff listing:
diff $Previous $Latest > Changes/diffs-$Previous


