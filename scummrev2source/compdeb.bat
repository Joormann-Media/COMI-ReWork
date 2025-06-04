@ECHO OFF
...\bin\dcc32 SCUMMRev.dpr -$R+ -U..\..\comp -V -GD -UCompiled -ECompiled -R..\..\lib /DDEBUG %1 %2 %3 %4 %5
if ERRORLEVEL == 0 ....\bc5\bin\td32 compiled\scummrev
