[Setup] 
#define AppVersion "3.05"
AppName=LangTranUpdate
#define AppName "LangTranUpdate"
AppVerName=LangTranUpdate Version {#AppVersion}
DefaultDirName={commondocs}\LangTranLocal
; DefaultDirName={userdocs}\LangTranLocal
DefaultGroupName=LangTranUpdate
#define AppFolder "LangTranLocal"
LicenseFile={#AppFolder}\Progs\HowToInstall.rtf
OutputDir=.\Output
OutputBaseFilename=LangTranUpdate-v{#AppVersion}-Setup
SetupIconFile={#AppFolder}\Progs\LangTran-icon.ico
Compression=lzma
SolidCompression=true
DisableStartupPrompt=false
ShowLanguageDialog=yes
DisableFinishedPage=no

[Languages]
Name: english; MessagesFile: compiler:Default.isl
Name: brazilianportuguese; MessagesFile: compiler:Languages\BrazilianPortuguese.isl
Name: catalan; MessagesFile: compiler:Languages\Catalan.isl
Name: czech; MessagesFile: compiler:Languages\Czech.isl
Name: danish; MessagesFile: compiler:Languages\Danish.isl
Name: dutch; MessagesFile: compiler:Languages\Dutch.isl
Name: finnish; MessagesFile: compiler:Languages\Finnish.isl
Name: french; MessagesFile: compiler:Languages\French.isl
Name: german; MessagesFile: compiler:Languages\German.isl
Name: hungarian; MessagesFile: compiler:Languages\Hungarian.isl
Name: italian; MessagesFile: compiler:Languages\Italian.isl
Name: norwegian; MessagesFile: compiler:Languages\Norwegian.isl
Name: polish; MessagesFile: compiler:Languages\Polish.isl
Name: portuguese; MessagesFile: compiler:Languages\Portuguese.isl
Name: russian; MessagesFile: compiler:Languages\Russian.isl
;Name: slovak; MessagesFile: compiler:Languages\Slovak.isl
Name: slovenian; MessagesFile: compiler:Languages\Slovenian.isl

[Messages]
;These messages override default.isl and the [language].isl files 
; so when we internationalize we'll have to become more sophisticated.
SelectDirLabel3=Setup will install the files for {#AppName} into the following folder.
SelectTasksLabel2=Select the additional tasks you would like Setup to perform while installing {#AppName}, then click Next. (Leave these boxes checked if you're not sure what to do here.)

ReadyLabel1=Setup is now ready to begin installing {#AppName} on your computer. 

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
;Name: quicklaunchicon; Description: {cm:CreateQuickLaunchIcon}; GroupDescription: {cm:AdditionalIcons}
;uncomment this to allow selection or not of the quicklaunchicons; you also need to add a Tasks: statement below under [Icons] (see desktopicons there)
Name: "RunFirstUpdate"; Description: "&Run the first update after control file is edited"; Flags: checkablealone

[Files]
Source: "{#AppFolder}\LangTranUpdate.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#AppFolder}\Progs\PruneArchive.sh"; DestDir: "{app}\Progs"; Flags: ignoreversion
Source: "{#AppFolder}\Progs\RsyncFolder.sh"; DestDir: "{app}\Progs"; Flags: ignoreversion
Source: "{#AppFolder}\Progs\version.txt"; DestDir: "{app}\Progs"; Flags: ignoreversion
Source: "{app}\LangTranList.txt"; DestDir: "{app}"; DestName: "LangTranPrev.txt"; Flags: ignoreversion external skipifsourcedoesntexist
Source: "{#AppFolder}\LangTranList.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "{app}\Behaviour.cmd"; DestDir: "{app}"; DestName: "BehaviourPrev.txt"; Flags: ignoreversion external skipifsourcedoesntexist
Source: "{#AppFolder}\Behaviour.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#AppFolder}\Progs\MIT license.txt"; DestDir: "{app}\Progs"; Flags: ignoreversion
Source: "{#AppFolder}\Progs\LangTran-icon.ico"; DestDir: "{app}\Progs"; Flags: ignoreversion
Source: "{#AppFolder}\Win_main\Basis_win\*"; DestDir: "{app}\Win_main\Basis_win"; Flags: ignoreversion createallsubdirs recursesubdirs

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\Update LangTran Files into the local folder"; Filename: "{app}\LangTranUpdate.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\Progs\LangTran-icon.ico"
Name: "{group}\List of folders to get"; Filename: "{app}\LangTranList.txt"; WorkingDir: "{app}"
Name: "{group}\Change behaviour of LangTranUpdate"; Filename: "{sys}\notepad.exe"; Parameters: "{app}\Behaviour.cmd"; WorkingDir: "{app}"; Comment: "To change the behaviour of LangTranUpdate"
Name: "{group}\MIT License"; Filename: "{app}\Progs\MIT license.txt"; WorkingDir: "{app}"
Name: "{group}\{cm:UninstallProgram,LangTranUpdate}"; Filename: "{uninstallexe}"
Name: "{userdesktop}\Update LangTran Files into the local folder"; Filename: "{app}\LangTranUpdate.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\Progs\LangTran-icon.ico"; Tasks: desktopicon
Name: "{userdesktop}\List of LangTran folders to get"; Filename: "{app}\LangTranList.txt"; WorkingDir: "{app}"
Name: "{userdesktop}\Change behaviour of LangTranUpdate"; Filename: "{sys}\notepad.exe"; Parameters: "{app}\Behaviour.cmd"; WorkingDir: "{app}"; Comment: "To change the behaviour of LangTranUpdate"
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\Update LangTran Files into the local folder"; Filename: "{app}\LangTranUpdate.cmd"; WorkingDir: "{app}"; IconFilename: "{app}\Progs\LangTran-icon.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\LangTranList.txt"; Flags: shellexec waituntilterminated; Description: "{cm:LaunchProgram, ""LangTranList.txt"" -- you must not uncheck this box!}"; StatusMsg: "Editing LangTranList.txt. Pls select lines to update, save & close editor."
Filename: "{app}\{#AppName}.cmd"; WorkingDir: "{app}"; Flags: shellexec waituntilterminated; Description: "Run {#AppName}.cmd to update files from LangTran server."; StatusMsg: "Updating your LangTranLocal files from the LangTran server . . ."; Tasks: RunFirstUpdate

[UninstallDelete]
Type: files; Name: "{app}\Progs\FoldersUpdated.txt"
