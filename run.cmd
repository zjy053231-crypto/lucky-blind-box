@echo off
chcp 65001 >nul
setlocal EnableExtensions
cd /d "%~dp0"
title Lucky Blind Box - 干饭盲盒

set "PORT=8765"

where py >nul 2>&1 && set "PYCMD=py -3"
if not defined PYCMD where python >nul 2>&1 && set "PYCMD=python"
if not defined PYCMD (
  echo 未找到 Python。本应用需要 Python 3，请到 python.org 安装后重试。
  pause
  exit /b 1
)

echo 正在启动干饭盲盒...
%PYCMD% serve.py %PORT%
if errorlevel 1 (
  echo.
  echo 启动失败。若端口 %PORT% 被占用，请关闭占用程序后重试。
  pause
)
