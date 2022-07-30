:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                                           ::
:: rearm (Rearm Every Activation-Related Mechanism)                          ::
:: Copyright (C) 2022 Gamers Against Weed                                    ::
::                                                                           ::
:: This program is free software: you can redistribute it and/or modify      ::
:: it under the terms of the GNU General Public License as published by      ::
:: the Free Software Foundation, either version 3 of the License, or         ::
:: (at your option) any later version.                                       ::
::                                                                           ::
:: This program is distributed in the hope that it will be useful,           ::
:: but WITHOUT ANY WARRANTY; without even the implied warranty of            ::
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             ::
:: GNU General Public License for more details.                              ::
::                                                                           ::
:: You should have received a copy of the GNU General Public License         ::
:: along with this program.  If not, see <https://www.gnu.org/licenses/>.    ::
::                                                                           ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinPE" /v InstRoot >NUL 2>&1
if %ERRORLEVEL% NEQ 0 echo This script requires to be run from Windows PE or Windows RE & exit /b 1
goto :main

:remove_file
if not exist %1 exit /b
attrib -s -h %1
del /f %1
exit /b

:remove_directory
if not exist %1 exit /b
attrib -s -h %1
rmdir /q /s %1
exit /b

:main
set "_version=1.0"
set "_target=%~d0"
if not exist "%_target%\Windows\system32\config\SYSTEM" echo Can't find Windows installation on %_target% & exit /b 1

echo ======================================================================
echo rearm (Rearm Every Activation-Related Mechanism) %_version%
echo https://github.com/Gamers-Against-Weed/rearm
echo ======================================================================
echo.
echo Cleaning licensing files on %_target%...

reg load HKLM\clean_temp "%_target%\Windows\system32\config\SYSTEM"
reg query "HKLM\clean_temp\ControlSet001\Control\{7746D80F-97E0-4E26-9543-26B41FC22F79}" >NUL 2>&1
if %ERRORLEVEL% EQU 0 reg delete "HKLM\clean_temp\ControlSet001\Control\{7746D80F-97E0-4E26-9543-26B41FC22F79}" /f
for /f %%i in ('reg query HKLM\clean_temp\WPA ^| find "8DEC0AF1-0341-4b93-85CD-72606C2DF94C"') do reg delete "%%i" /f
reg unload HKLM\clean_temp

call :remove_file "%_target%\ProgramData\Microsoft\Windows\ClipSVC\tokens.dat"
call :remove_directory "%_target%\Windows\System32\spp\store_test\2.0\cache"
call :remove_file "%_target%\Windows\System32\spp\store_test\2.0\data.dat"
call :remove_file "%_target%\Windows\System32\spp\store_test\2.0\tokens.dat"
call :remove_directory "%_target%\Windows\System32\spp\store\2.0\cache"
call :remove_file "%_target%\Windows\System32\spp\store\2.0\data.dat"
call :remove_file "%_target%\Windows\System32\spp\store\2.0\tokens.dat"
call :remove_directory "%_target%\Windows\System32\spp\store\cache"
call :remove_file "%_target%\Windows\System32\spp\store\data.dat"
call :remove_file "%_target%\Windows\System32\spp\store\tokens.dat"
call :remove_file "%_target%\Windows\ServiceProfiles\NetworkService\AppData\Roaming\Microsoft\SoftwareProtectionPlatform\tokens.dat"
call :remove_directory "%_target%\Windows\ServiceProfiles\NetworkService\AppData\Roaming\Microsoft\SoftwareProtectionPlatform\cache"
