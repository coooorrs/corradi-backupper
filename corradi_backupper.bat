@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Corradi Backupper
color fa

:::                               _ _
:::                              | (_)
:::   ___ ___  _ __ _ __ __ _  __| |_
:::  / __/ _ \| '__| '__/ _` |/ _` | |
::: | (_| (_) | |  | | | (_| | (_| | |
:::  \___\___/|_|  |_| \__,_|\__,_|_|
:::  _                _
::: | |              | |
::: | |__   __ _  ___| | ___   _ _ __  _ __   ___ _ __
::: | '_ \ / _` |/ __| |/ / | | | '_ \| '_ \ / _ \ '__|
::: | |_) | (_| | (__|   <| |_| | |_) | |_) |  __/ |
::: |_.__/ \__,_|\___|_|\_\\__,_| .__/| .__/ \___|_|
:::                             | |   | |
:::                             |_|   |_|
::: =======================================
:::     Coooorrs      Since 2008 <3
::: =======================================
for /f "delims=: tokens=*" %%A in ('findstr /b ::: ^< "%~f0"') do @echo(%%A

:menu
echo.
echo [A] Attiva Corradi Backupper
echo [B] Esci dal programma
echo.
choice /c AB /M "Scelta:"

if errorlevel 2 goto exit
if errorlevel 1 goto start

:start
cls
echo.
echo ========================================
echo    CORRADI BACKUPPER
echo ========================================
echo.

REM --- CONFIG: imposta qui i percorsi ---
set "SOURCE=C:\TuaCartellaOrigine"
set "DESTINATION=D:\TuaCartellaDestinazione"
REM --------------------------------------

set "LOG=%~dp0backup_xcopy.log"
set "EXCLUDE=%~dp0exclude_xcopy.txt"

echo Origine      : "%SOURCE%"
echo Destinazione : "%DESTINATION%"
echo Log          : "%LOG%"
if exist "%EXCLUDE%" (
  echo Exclude     : "%EXCLUDE%"
) else (
  echo Exclude     : (nessuno) - file non trovato: "%EXCLUDE%"
)

echo.
echo [1] Backup completo (copia tutto)
echo [2] Backup incrementale (solo file piu' recenti)
echo [3] Simulazione (lista cosa copierebbe, non copia)
echo [4] Torna al menu
echo.
choice /c 1234 /M "Seleziona:"

if errorlevel 4 goto menu
if errorlevel 3 goto dryrun
if errorlevel 2 goto incremental
if errorlevel 1 goto full

:precheck
if not exist "%SOURCE%" (
  echo ERRORE: cartella origine non esiste.
  pause
  goto menu
)
if not exist "%DESTINATION%" (
  mkdir "%DESTINATION%" >nul 2>&1
)

REM Intestazione log
>>"%LOG%" echo.
>>"%LOG%" echo ==================================================
>>"%LOG%" echo Avvio: %date% %time%
>>"%LOG%" echo SOURCE=%SOURCE%
>>"%LOG%" echo DEST=%DESTINATION%
>>"%LOG%" echo ==================================================
goto :eof

:full
call :precheck
echo.
echo Avvio backup completo...
echo.

set "COMMON_OPTS=/S /E /H /C /I /Y /R /K /V /F"
if exist "%EXCLUDE%" (
  xcopy "%SOURCE%\*" "%DESTINATION%\" %COMMON_OPTS% /exclude:"%EXCLUDE%" >>"%LOG%" 2>&1
) else (
  xcopy "%SOURCE%\*" "%DESTINATION%\" %COMMON_OPTS% >>"%LOG%" 2>&1
)

call :handle_errorlevel
pause
goto menu

:incremental
call :precheck
echo.
echo Avvio backup incrementale (XCOPY /D)...
echo.

set "COMMON_OPTS=/S /E /H /C /I /Y /R /K /V /F /D"
if exist "%EXCLUDE%" (
  xcopy "%SOURCE%\*" "%DESTINATION%\" %COMMON_OPTS% /exclude:"%EXCLUDE%" >>"%LOG%" 2>&1
) else (
  xcopy "%SOURCE%\*" "%DESTINATION%\" %COMMON_OPTS% >>"%LOG%" 2>&1
)

call :handle_errorlevel
pause
goto menu

:dryrun
call :precheck
echo.
echo Simulazione: genero lista file (XCOPY /L)...
echo.

set "COMMON_OPTS=/S /E /H /C /I /Y /R /K /V /F /L"
if exist "%EXCLUDE%" (
  xcopy "%SOURCE%\*" "%DESTINATION%\" %COMMON_OPTS% /exclude:"%EXCLUDE%" >>"%LOG%" 2>&1
) else (
  xcopy "%SOURCE%\*" "%DESTINATION%\" %COMMON_OPTS% >>"%LOG%" 2>&1
)

call :handle_errorlevel
echo (Vedi log: "%LOG%")
pause
goto menu

:handle_errorlevel
REM Exit code XCOPY: 0 ok, 1 nessun file, 2 CTRL+C, 4 init error, 5 write error
set "RC=%errorlevel%"
echo.
echo XCOPY exit code: %RC%
>>"%LOG%" echo.
>>"%LOG%" echo Fine: %date% %time% - ExitCode=%RC%

if "%RC%"=="0" echo OK: file copiati senza errori.
if "%RC%"=="1" echo Nota: nessun file trovato da copiare.
if "%RC%"=="2" echo ERRORE: operazione interrotta (CTRL+C).
if "%RC%"=="4" echo ERRORE: problema di inizializzazione (memoria/spazio/sintassi).
if "%RC%"=="5" echo ERRORE: problema di scrittura su disco.
goto :eof

:exit
echo.
echo Uscita...
timeout /t 2 >nul
exit /b
