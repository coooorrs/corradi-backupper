@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Corradi Backupper (XCOPY)
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
echo [A] Attiva Corradi Backupper (XCOPY)
echo [B] Esci dal programma
echo.
choice /c AB /M "Scelta:"

if errorlevel 2 goto exit
if errorlevel 1 goto start

:start
cls
echo.
echo ========================================
echo    CORRADI BACKUPPER - CONFIGURAZIONE
echo ========================================
echo.

REM Chiedi cartella sorgente
set "SOURCE="
echo Inserisci il percorso completo della cartella da copiare
echo (Esempio: C:\Users\Corradi\Documenti\MioProgetto)
echo.
set /p "SOURCE=Cartella origine: "

REM Rimuovi eventuali virgolette
set "SOURCE=%SOURCE:"=%"

REM Controlla se esiste
if not exist "%SOURCE%" (
    echo.
    echo ERRORE: La cartella "%SOURCE%" non esiste!
    echo.
    pause
    goto start
)

REM Chiedi disco/cartella destinazione
set "DESTINATION="
echo.
echo Inserisci il percorso di destinazione (disco o cartella)
echo (Esempio: D:\ oppure E:\Backup\MioProgetto)
echo.
set /p "DESTINATION=Destinazione: "

REM Rimuovi eventuali virgolette
set "DESTINATION=%DESTINATION:"=%"

REM Crea la cartella destinazione se non esiste
if not exist "%DESTINATION%" (
    echo.
    echo La cartella destinazione non esiste. Vuoi crearla?
    choice /c SN /M "Creare %DESTINATION%?"
    if errorlevel 2 goto start
    mkdir "%DESTINATION%" 2>nul
    if errorlevel 1 (
        echo ERRORE: Impossibile creare la cartella di destinazione!
        pause
        goto start
    )
)

REM Mostra riepilogo
cls
echo.
echo ========================================
echo    RIEPILOGO BACKUP
echo ========================================
echo.
echo Origine      : "%SOURCE%"
echo Destinazione : "%DESTINATION%"
echo.

REM Menu tipo backup
echo [1] Backup completo (copia tutto)
echo [2] Backup incrementale (solo file piu' recenti)
echo [3] Simulazione (mostra cosa copierebbe)
echo [4] Annulla e torna al menu
echo.
choice /c 1234 /M "Seleziona il tipo di backup:"

if errorlevel 4 goto menu
if errorlevel 3 goto dryrun
if errorlevel 2 goto incremental
if errorlevel 1 goto full

:full
echo.
echo ========================================
echo    BACKUP COMPLETO IN CORSO...
echo ========================================
echo.

REM Parametri XCOPY:
REM /S = copia sottocartelle non vuote
REM /E = copia anche sottocartelle vuote
REM /H = copia file nascosti e di sistema
REM /C = continua anche in caso di errori
REM /I = assume che destinazione sia una cartella
REM /Y = sovrascrive senza chiedere
REM /R = sovrascrive anche file read-only
REM /K = mantiene attributi read-only
REM /V = verifica i file copiati

xcopy "%SOURCE%\*" "%DESTINATION%\" /S /E /H /C /I /Y /R /K /V /F

call :handle_errorlevel
pause
goto menu

:incremental
echo.
echo ========================================
echo    BACKUP INCREMENTALE IN CORSO...
echo ========================================
echo.

REM /D = copia solo file piu' recenti della destinazione
xcopy "%SOURCE%\*" "%DESTINATION%\" /S /E /H /C /I /Y /R /K /V /F /D

call :handle_errorlevel
pause
goto menu

:dryrun
echo.
echo ========================================
echo    SIMULAZIONE (nessun file copiato)
echo ========================================
echo.

REM /L = mostra solo cosa verrebbe copiato senza copiare
xcopy "%SOURCE%\*" "%DESTINATION%\" /S /E /H /C /I /Y /R /K /V /F /L

call :handle_errorlevel
pause
goto menu

:handle_errorlevel
echo.
echo ========================================
set "RC=%errorlevel%"

if "%RC%"=="0" (
    echo RISULTATO: File copiati con successo!
    echo Exit code: %RC%
)
if "%RC%"=="1" (
    echo RISULTATO: Nessun file trovato da copiare.
    echo Exit code: %RC%
)
if "%RC%"=="2" (
    echo ERRORE: Operazione interrotta dall'utente (CTRL+C).
    echo Exit code: %RC%
)
if "%RC%"=="4" (
    echo ERRORE: Problema di inizializzazione (memoria/sintassi).
    echo Exit code: %RC%
)
if "%RC%"=="5" (
    echo ERRORE: Errore di scrittura su disco.
    echo Exit code: %RC%
)
echo ========================================
goto :eof

:exit
echo.
echo Uscita dal programma...
timeout /t 2 >nul
exit /b
