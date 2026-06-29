@echo off

echo =======================================================
echo   Hello, from inside the GitHub Repo!
echo =======================================================
echo.
echo   This repo demonstrates how to create a
echo   production-ready Jenkins pipeline structure.
echo.
echo =======================================================
echo   STRUCTURE EXPLANATION
echo =======================================================
echo.
echo   [1] Jenkins Job UI
echo              ^|
echo              v
echo   [2] Job triggers the Jenkinsfile
echo       (already exists in the jenkins/ folder)
echo              ^|
echo              v
echo   [3] Jenkinsfile clones the GitHub repo
echo       and runs the Jenkinsfile from inside the repo
echo              ^|
echo              v
echo   [4] Jenkinsfile performs pipeline operations
echo       (build, test, deploy, etc.)
echo.
echo =======================================================
