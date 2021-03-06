@echo off

REM ---------------------------------------------------------------------------
REM   Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
REM
REM   Licensed under the Apache License, Version 2.0 (the "License");
REM   you may not use this file except in compliance with the License.
REM   You may obtain a copy of the License at
REM
REM   http://www.apache.org/licenses/LICENSE-2.0
REM
REM   Unless required by applicable law or agreed to in writing, software
REM   distributed under the License is distributed on an "AS IS" BASIS,
REM   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM   See the License for the specific language governing permissions and
REM   limitations under the License.

rem ----- if JAVA_HOME is not set we're not happy ------------------------------
:checkJava

if "%JAVA_HOME%" == "" goto noJavaHome
if not exist "%JAVA_HOME%\bin\java.exe" goto noJavaHome
goto checkServer

:noJavaHome
echo "You must set the JAVA_HOME variable before running CARBON."
goto end

rem ----- Only set CARBON_HOME if not already set ----------------------------
:checkServer
rem %~sdp0 is expanded pathname of the current script under NT with spaces in the path removed
if "%CARBON_HOME%"=="" set CARBON_HOME=%~sdp0..\..\..
SET curDrive=%cd:~0,1%
SET wsasDrive=%CARBON_HOME:~0,1%
if not "%curDrive%" == "%wsasDrive%" %wsasDrive%:

rem ----- Only set RUNTIME_HOME if not already set ----------------------------
:setRuntimeHome
if "%RUNTIME_HOME%"=="" set RUNTIME_HOME=%~sdp0..
rem --- derive RUNTIME NAME from the RUNTIME_HOME path.
cd /d %RUNTIME_HOME%
set path1=%cd%
cd ..
set path2=%cd%
call set "RUNTIME=%%path1:%path2%\=%%"

rem find CARBON_HOME if it does not exist due to either an invalid value passed
rem by the user or the %0 problem on Windows 9x
if not exist "%CARBON_HOME%\bin\kernel-version.txt" goto noServerHome

goto commandLifecycle

:noServerHome
echo CARBON_HOME is set incorrectly or CARBON could not be located. Please set CARBON_HOME.
goto end

:commandLifecycle
goto findJdk

:findJdk

set CMD=RUN %*

:checkJdk16
"%JAVA_HOME%\bin\java" -version 2>&1 | findstr /r "1.[8]" >NUL
IF ERRORLEVEL 1 goto unknownJdk
goto jdk16

:unknownJdk
echo Starting WSO2 Carbon (in unsupported JDK)
echo [ERROR] CARBON is supported only on JDK 1.8
goto jdk16

:jdk16
goto runTool

rem ----------------- Execute The Requested Command ----------------------------
:runTool
echo JAVA_HOME environment variable is set to %JAVA_HOME%
echo CARBON_HOME environment variable is set to %CARBON_HOME%
echo RUNTIME_HOME environment variable is set to %RUNTIME_HOME%

cd %RUNTIME_HOME%
set CMD_LINE_ARGS= -Dcarbon.home="%CARBON_HOME%" -Dwso2.runtime.path="%RUNTIME_HOME%" -Dwso2.runtime="%RUNTIME%"
"%JAVA_HOME%\bin\java" %CMD_LINE_ARGS% -jar bin\bootstrap\tools\org.wso2.carbon.secvault.ciphertool.jar %*

:end
goto endlocal

:endlocal

:END
