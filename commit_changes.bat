@echo off
echo Committing changes to Git repository...

"C:\Program Files\Git\bin\git.exe" add .
"C:\Program Files\Git\bin\git.exe" commit -m "Added UAT environment and WWW access capability, updated README documentation"
"C:\Program Files\Git\bin\git.exe" push

echo Done!
pause
