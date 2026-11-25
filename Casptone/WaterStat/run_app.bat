@echo off
title WaterStat - R Shiny Application
echo ======================================================================
echo Launching WaterStat: Interactive Statistical Water Quality Framework
echo ======================================================================
echo.

set "RSCRIPT=C:\Program Files\R\R-4.6.1\bin\x64\Rscript.exe"

if exist "%RSCRIPT%" (
    echo Using R runtime: %RSCRIPT%
) else (
    where Rscript >nul 2>&1
    if %errorlevel% equ 0 (
        set "RSCRIPT=Rscript"
        echo Using R from system PATH
    ) else (
        echo [ERROR] R runtime was not found. Please ensure R is installed.
        pause
        exit /b 1
    )
)

echo Starting Shiny web server at http://127.0.0.1:3838 ...
echo Press Ctrl+C in this window to stop the server.
echo.

"%RSCRIPT%" -e "shiny::runApp('.', port = 3838, launch.browser = TRUE)"

pause
