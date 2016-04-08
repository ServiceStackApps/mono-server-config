@echo off

if "%1"=="" goto help

set HOST=%2
REM set /p user="User name" < nul
REM set /p pwd="Password" < nul

echo option echo off > deploy.txt
echo option batch on >> deploy.txt
echo option confirm off >> deploy.txt
echo open sftp://%USER%:%PWD%@%HOST% >> deploy.txt
echo #lcd "$1" >> deploy.txt
echo cd hello-app >> deploy.txt
echo put -nopermissions -nopreservetime "%1\*" >> deploy.txt
echo exit >> deploy.txt

"%ProgramFiles(x86)%\WinSCP\winscp.com" /script=deploy.txt
del deploy.txt

goto end

:help
echo Usage: deploy.bat ^<Source Dir^> [Remote Host]
echo Deploys directory to remote server in hello-app directory using SFTP


:end
