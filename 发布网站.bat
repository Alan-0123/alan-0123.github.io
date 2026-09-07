@echo off
title 一键发布个人网站
echo.
echo  正在发布网站到 GitHub Pages...
echo  请等待部署完成（约 1 分钟）
echo  请确保保存了 index.html / resume.html 等文件的修改
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
echo.
pause