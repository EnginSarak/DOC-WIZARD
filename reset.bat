@echo off
chcp 65001 >nul
title DOC WIZARD - RESET
setlocal EnableDelayedExpansion
cd /d "%~dp0"

cls
echo.
echo   ====================================================================
echo    DOC WIZARD  -  RESET
echo   ====================================================================
echo.
echo    This removes all personal settings from this copy, so the tool
echo    starts with the first time setup on the next run.
echo.
echo    Will be reset:
echo      - _doc_wizard_settings.txt   (folders, printer, banner style)
echo      - _doc_wizard_pairs.txt      (remembered PAC / PWS pairs)
echo      - _doc_wizard_printed.txt    (printed markers)
echo.
echo    Will be kept:
echo      - _doc_wizard.ps1            (the program)
echo      - pumplist_template.xlsx     (pump list template)
echo      - pump_control_template.xlsx (control file template)
echo      - groupage_template.xlsx     (groupage template)
echo      - DOC WIZARD.bat, docwizard.ico
echo.

if exist "_doc_wizard_settings.txt" (
    echo   --------------------------------------------------------------------
    echo    Current settings:
    echo.
    for /f "usebackq delims=" %%L in ("_doc_wizard_settings.txt") do echo      %%L
    echo.
)

echo   --------------------------------------------------------------------
echo.
set "ANSWER="
set /p "ANSWER=   Type  RESET  and press Enter to confirm (anything else = cancel): "

if /i not "!ANSWER!"=="RESET" (
    echo.
    echo    Cancelled. Nothing was changed.
    echo.
    pause
    exit /b 0
)

echo.
if exist "_doc_wizard_settings.txt" (
    del /f /q "_doc_wizard_settings.txt" >nul 2>&1
    if exist "_doc_wizard_settings.txt" (
        echo    ERROR   : _doc_wizard_settings.txt could not be deleted.
    ) else (
        echo    removed : _doc_wizard_settings.txt
    )
) else (
    echo    skipped : _doc_wizard_settings.txt  ^(not present^)
)

break > "_doc_wizard_pairs.txt"
echo    cleared : _doc_wizard_pairs.txt

break > "_doc_wizard_printed.txt"
echo    cleared : _doc_wizard_printed.txt

echo.
echo   ====================================================================
echo    Done. This copy is ready to be handed over to a colleague.
echo    On the next start DOC WIZARD asks for folders and printer again.
echo   ====================================================================
echo.
pause
exit /b 0
