@echo off
REM Fire Tree Visualizer - Windows Batch Wrapper
REM This runs the bash script using Git Bash or WSL

REM Try Git Bash first
where bash >nul 2>&1
if %errorlevel% == 0 (
    bash fire-tree.sh %*
    goto :end
)

REM Try WSL
where wsl >nul 2>&1
if %errorlevel% == 0 (
    wsl bash fire-tree.sh %*
    goto :end
)

REM Fallback message
echo Fire Tree requires Git Bash or WSL on Windows
echo Please install Git for Windows or Windows Subsystem for Linux

:end