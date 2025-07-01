:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                                           ::
:: rearm (Rearm Every Activation-Related Mechanism)                          ::
:: Copyright (C) 2025 asdcorp                                                ::
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
del /a /f %1 >NUL 2>&1
exit /b

:remove_directory
if not exist %1 exit /b
attrib -s -h %1 >NUL 2>&1
rmdir /q /s %1 >NUL 2>&1
exit /b

:remove_registry
reg query %* >NUL 2>&1
if %ERRORLEVEL% EQU 0 reg delete %* /f >NUL 2>&1
exit /b

:clear_wpa
set "_wpa_cleanup_file=%_target%\REARM_WPA_CLEANUP_%RANDOM%.REG"
set "_wpa_count=0"

(echo Windows Registry Editor Version 5.00 && echo.)>"%_wpa_cleanup_file%"

echo [%time%] Enumerating WPA registry... This may take a while.
for /f "delims=" %%i in ('reg query HKLM\clean_temp\WPA ^| find "8DEC0AF1-0341-4b93-85CD-72606C2DF94C"') do (
  set /a _wpa_count+=1
  echo [-%%i]>>"%_wpa_cleanup_file%"
)

echo [%time%] Deleting %_wpa_count% WPA registry keys...
reg import "%_wpa_cleanup_file%" >NUL 2>&1

del "%_wpa_cleanup_file%"
exit /b

:main
set "_version=2.0"
set "_target=%~d0"
if not exist "%_target%\Windows\system32\config\SYSTEM" echo Can't find Windows installation on %_target% & exit /b 1

echo ======================================================================
echo rearm (Rearm Every Activation-Related Mechanism) %_version%
echo https://github.com/asdcorp/rearm
echo ======================================================================
echo.
echo [%time%] Proceeding with licensing cleanup on %_target%

:: ========== Registry ==========
::WPA + ClipSVC
reg load HKLM\clean_temp "%_target%\Windows\system32\config\SYSTEM" >NUL 2>&1 || exit /b 1
call :clear_wpa

echo [%time%] Cleaning up other licensing registry entries...

call :remove_registry "HKLM\clean_temp\ControlSet001\Control\{7746D80F-97E0-4E26-9543-26B41FC22F79}"
call :remove_registry "HKLM\clean_temp\ControlSet001\Services\ClipSVC\Parameters" /v SubscriptionList
reg unload HKLM\clean_temp >NUL 2>&1

::SoftwareProtectionPlatform + OSPPSVC data store
reg load HKLM\clean_temp "%_target%\Windows\System32\config\SOFTWARE" >NUL 2>&1 || exit /b 1
call :remove_registry "HKLM\clean_temp\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v ServiceSessionId
call :remove_registry "HKLM\clean_temp\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v LicStatusArray
call :remove_registry "HKLM\clean_temp\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v PolicyValuesArray
call :remove_registry "HKLM\clean_temp\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" /v actionlist
call :remove_registry "HKLM\clean_temp\Microsoft\OfficeSoftwareProtectionPlatform\data" /v Directory
reg unload HKLM\clean_temp >NUL 2>&1

::.DEFAULT IdentityCRL
reg load HKLM\clean_temp "%_target%\Windows\System32\config\DEFAULT" >NUL 2>&1
call :remove_registry "HKLM\clean_temp\Software\Microsoft\IdentityCRL"
reg unload HKLM\clean_temp >NUL 2>&1

::S-1-5-19 IdentityCRL
reg load HKLM\clean_temp "%_target%\Windows\ServiceProfiles\LocalService\NTUSER.DAT" >NUL 2>&1
call :remove_registry "HKLM\clean_temp\Software\Microsoft\IdentityCRL"
reg unload HKLM\clean_temp >NUL 2>&1

::S-1-5-20 IdentityCRL
reg load HKLM\clean_temp "%_target%\Windows\ServiceProfiles\NetworkService\NTUSER.DAT" >NUL 2>&1
call :remove_registry "HKLM\clean_temp\Software\Microsoft\IdentityCRL"
reg unload HKLM\clean_temp >NUL 2>&1

:: ========== Files ==========
echo [%time%] Cleaning up licensing files...

::ClipSVC
call :remove_file "%_target%\ProgramData\Microsoft\Windows\ClipSVC\tokens.dat"

::Windows 10/11 Insider
call :remove_directory "%_target%\Windows\System32\spp\store_test\2.0\cache"
call :remove_file "%_target%\Windows\System32\spp\store_test\2.0\data.dat"
call :remove_file "%_target%\Windows\System32\spp\store_test\2.0\tokens.dat"

::Windows 8.1/10/11
call :remove_directory "%_target%\Windows\System32\spp\store\2.0\cache"
call :remove_file "%_target%\Windows\System32\spp\store\2.0\data.dat"
call :remove_file "%_target%\Windows\System32\spp\store\2.0\tokens.dat"

::Windows 8
call :remove_directory "%_target%\Windows\System32\spp\store\cache"
call :remove_file "%_target%\Windows\System32\spp\store\data.dat"
call :remove_file "%_target%\Windows\System32\spp\store\tokens.dat"

::Windows 7
call :remove_file "%_target%\Windows\ServiceProfiles\NetworkService\AppData\Roaming\Microsoft\SoftwareProtectionPlatform\tokens.dat"
call :remove_file "%_target%\Windows\System32\7B296FB0-376B-497e-B012-9C450E1B7327-*.C7483456-A289-439d-8115-601632D005A0"
call :remove_directory "%_target%\Windows\ServiceProfiles\NetworkService\AppData\Roaming\Microsoft\SoftwareProtectionPlatform\cache"

::OSPPSVC
call :remove_file "%_target%\ProgramData\Microsoft\OfficeSoftwareProtectionPlatform\tokens.dat"
call :remove_directory "%_target%\ProgramData\Microsoft\OfficeSoftwareProtectionPlatform\Cache"

echo [%time%] Done.
