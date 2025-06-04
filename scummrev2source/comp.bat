@ECHO OFF
...\bin\dcc32 SCUMMRev.dpr -$R- -H -W -U..\..\comp -UCompiled -NCompiled -ECompiled -R..\..\lib %1 %2 %3 %4 %5
if ERRORLEVEL == 0 compiled\scummrev
