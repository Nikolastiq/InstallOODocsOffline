@echo off

REM Install Visual C++ Redistributables
echo Installing Visual C++ (2013) Redistributables
vcredist_x64.exe /quiet

REM Install Additional Visual C++ Redistributables
echo Installing Additional Visual C++ (2015-2022) Redistributables
VC_redist.x64.exe /quiet

REM Install Python
echo Installing Python
python-3.11.3-amd64.exe /quiet TargetDir="C:\Python" InstallAllUsers=0 PrependPath=1

REM Install Redis
echo Installing Redis
msiexec /i Redis-x64-5.0.10.msi /quiet /norestart

REM Install OTP (Open Telecom Platform)
echo Installing OTP
otp_win64_26.2.1.exe /S

REM Install RabbitMQ Server
echo Installing RabbitMQ Server
rabbitmq-server-3.12.11.exe /S

REM Install FireDaemon OpenSSL with specific options
echo Installing FireDaemon OpenSSL
FireDaemon-OpenSSL-x64-3.3.0.exe /exenoui /qn /norestart REBOOT=ReallySuppress ADJUSTSYSTEMPATHENV=yes

REM Install Certbot
echo Installing Certbot
certbot-beta-installer-win32.exe /S

REM Install PostgreSQL with unattended options
echo Installing PostgreSQL. This may take a while...
postgresql-12.17-1-windows-x64.exe --unattendedmodeui none --install_runtimes 0 --mode unattended

REM Wait for PostgreSQL installation to complete
REM Adjust the timeout duration if necessary to ensure PostgreSQL is fully installed
timeout /t 10 /nobreak > nul

REM Ensure the directory for pgpass.conf exists
set "PGPASS_DIR=%APPDATA%\postgresql"
if not exist "%PGPASS_DIR%" (
    echo Creating directory for pgpass.conf
    mkdir "%PGPASS_DIR%"
    if %ERRORLEVEL% NEQ 0 (
        echo Error creating directory %PGPASS_DIR%.
        exit /b %ERRORLEVEL%
    )
)

echo localhost:5432:*:postgres:postgres> "%APPDATA%\postgresql\pgpass.conf"

REM Change directory to PostgreSQL bin folder
cd /d "C:\Program Files\PostgreSQL\12\bin"

REM Create a new PostgreSQL user with a password
echo Creating PostgreSQL user and database
psql -U postgres -c "CREATE USER onlyoffice WITH PASSWORD 'onlyoffice';"
psql -U postgres -c "CREATE DATABASE onlyoffice OWNER onlyoffice;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE onlyoffice TO onlyoffice;"

del "%APPDATA%\postgresql\pgpass.conf"

REM Indicate that all installations and database setup are complete
echo All installations and database setup are complete.

REM Ask user if they want to install OnlyOffice Docs
set /p installOnlyOffice=Do you want to install OnlyOffice Docs? (yes/no): 

if /i "%installOnlyOffice%"=="yes" (
    REM Get the current directory
    set "currentDir=%cd%"
    echo Current directory is %currentDir%.

    REM Check and run the appropriate OnlyOffice installer
    if exist "%currentDir%\onlyoffice-documentserver.exe" (
        echo Installing OnlyOffice DocumentServer...
        "%currentDir%\onlyoffice-documentserver.exe"
    ) else if exist "%currentDir%\onlyoffice-documentserver-de.exe" (
        echo Installing OnlyOffice DocumentServer DE...
        "%currentDir%\onlyoffice-documentserver-de.exe"
    ) else if exist "%currentDir%\onlyoffice-documentserver-ee.exe" (
        echo Installing OnlyOffice DocumentServer EE...
        "%currentDir%\onlyoffice-documentserver-ee.exe"
    ) else (
        echo No OnlyOffice DocumentServer installer found in the current directory.
    )
) else (
    echo Skipping OnlyOffice Docs installation.
)

REM Pause the script to allow the user to review the output
pause
