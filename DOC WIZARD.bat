@echo off
chcp 65001 >nul
title DOC WIZARD
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_doc_wizard.ps1" "%~dp0.."
