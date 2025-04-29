
#WSUS #обновления #update

В некоторых случаях ошибки обновления ОС возникают в результате повреждения системных файлов и компонентов Windows. К счастью, и то, и другое поддается исправлению, причем довольно быстро. Вызывает консоль и выполняем в ней несколько полезных команд — это все, что вам необходимо сделать.

1. Кликните ПКМ на Пуск и выберите **Командная строка (администратор)**. Также можно нажать Win+R, прописать в пустой строчке **cmd** и нажать комбинацию Ctrl+Shift+Enter. Как альтернатива, можете использовать PowerShell.
2. Впишите в консоль команду **sfc /scannow** и нажмите Enter.
3. Подождите окончания работы утилиты SFC и ознакомьтесь с результатами.
4. Перезагрузите свой ПК и снова откройте консоль.
5. Выполните следующие три команды:
    - **DISM /Online /Cleanup-Image /CheckHealth**
    - **DISM /Online /Cleanup-Image /ScanHealth**
    - **DISM /Online /Cleanup-Image /RestoreHealth**
6. Еще раз перезагрузите ПК.

Войдите в Центр обновления Windows и проверьте наличие ошибки 0x80d02002.


Сохраните текстовик под именем «Сброс Центра обновления» и поменяйте его расширение с .txt на .cmd. Теперь нажмите **ПКМ** на файл **Сброс Центра обновления.bat** и выберите **Запуск от имени администратора**. Подождите несколько секунд, чтобы процесс сброса завершился и перезагрузите свой ПК. Теперь ошибка 0x80d02002 должна оставить вас в покое.

``` cmd
: Run the reset Windows Update components.
:: void components();
:: /*************************************************************************************/
:components
:: —— Stopping the Windows Update services ——
call :print Stopping the Windows Update services.
net stop bits

call :print Stopping the Windows Update services.
net stop wuauserv

call :print Stopping the Windows Update services.
net stop appidsvc

call :print Stopping the Windows Update services.
net stop cryptsvc

call :print Canceling the Windows Update process.
taskkill /im wuauclt.exe /f

:: —— Checking the services status ——
call :print Checking the services status.

sc query bits | findstr /I /C:»STOPPED»
if %errorlevel% NEQ 0 (
echo. Failed to stop the BITS service.
echo.
echo.Press any key to continue . . .
pause>nul
goto :eof
)

call :print Checking the services status.

sc query wuauserv | findstr /I /C:»STOPPED»
if %errorlevel% NEQ 0 (
echo. Failed to stop the Windows Update service.
echo.
echo.Press any key to continue . . .
pause>nul
goto :eof
)

call :print Checking the services status.

sc query appidsvc | findstr /I /C:»STOPPED»
if %errorlevel% NEQ 0 (
sc query appidsvc | findstr /I /C:»OpenService FAILED 1060″
if %errorlevel% NEQ 0 (
echo. Failed to stop the Application Identity service.
echo.
echo.Press any key to continue . . .
pause>nul
if %family% NEQ 6 goto :eof
)
)

call :print Checking the services status.

sc query cryptsvc | findstr /I /C:»STOPPED»
if %errorlevel% NEQ 0 (
echo. Failed to stop the Cryptographic Services service.
echo.
echo.Press any key to continue . . .
pause>nul
goto :eof
)

:: —— Delete the qmgr*.dat files ——
call :print Deleting the qmgr*.dat files.

del /s /q /f «%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\qmgr*.dat»
del /s /q /f «%ALLUSERSPROFILE%\Microsoft\Network\Downloader\qmgr*.dat»

:: —— Renaming the softare distribution folders backup copies ——
call :print Deleting the old software distribution backup copies.

cd /d %SYSTEMROOT%

if exist «%SYSTEMROOT%\winsxs\pending.xml.bak» (
del /s /q /f «%SYSTEMROOT%\winsxs\pending.xml.bak»
)
if exist «%SYSTEMROOT%\SoftwareDistribution.bak» (
rmdir /s /q «%SYSTEMROOT%\SoftwareDistribution.bak»
)
if exist «%SYSTEMROOT%\system32\Catroot2.bak» (
rmdir /s /q «%SYSTEMROOT%\system32\Catroot2.bak»
)
if exist «%SYSTEMROOT%\WindowsUpdate.log.bak» (
del /s /q /f «%SYSTEMROOT%\WindowsUpdate.log.bak»
)

call :print Renaming the software distribution folders.

if exist «%SYSTEMROOT%\winsxs\pending.xml» (
takeown /f «%SYSTEMROOT%\winsxs\pending.xml»
attrib -r -s -h /s /d «%SYSTEMROOT%\winsxs\pending.xml»
ren «%SYSTEMROOT%\winsxs\pending.xml» pending.xml.bak
)
if exist «%SYSTEMROOT%\SoftwareDistribution» (
attrib -r -s -h /s /d «%SYSTEMROOT%\SoftwareDistribution»
ren «%SYSTEMROOT%\SoftwareDistribution» SoftwareDistribution.bak
if exist «%SYSTEMROOT%\SoftwareDistribution» (
echo.
echo. Failed to rename the SoftwareDistribution folder.
echo.
echo.Press any key to continue . . .
pause>nul
goto :eof
)
)
if exist «%SYSTEMROOT%\system32\Catroot2» (
attrib -r -s -h /s /d «%SYSTEMROOT%\system32\Catroot2»
ren «%SYSTEMROOT%\system32\Catroot2» Catroot2.bak
)
if exist «%SYSTEMROOT%\WindowsUpdate.log» (
attrib -r -s -h /s /d «%SYSTEMROOT%\WindowsUpdate.log»
ren «%SYSTEMROOT%\WindowsUpdate.log» WindowsUpdate.log.bak
)

:: —— Reset the BITS service and the Windows Update service to the default security descriptor ——
call :print Reset the BITS service and the Windows Update service to the default security descriptor.

sc.exe sdset wuauserv D:(A;CI;CCLCSWRPLORC;;;AU)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)S:(AU;FA;CCDCLCSWRPWPDTLOSDRCWDWO;;;WD)
sc.exe sdset bits D:(A;CI;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)S:(AU;SAFA;WDWO;;;BA)
sc.exe sdset cryptsvc D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)(A;;CCLCSWRPWPDTLOCRRC;;;SO)(A;;CCLCSWLORC;;;AC)(A;;CCLCSWLORC;;;S-1-15-3-1024-3203351429-2120443784-2872670797-1918958302-2829055647-4275794519-765664414-2751773334)
sc.exe sdset trustedinstaller D:(A;CI;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)(A;;CCDCLCSWRPWPDTLOCRRC;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)S:(AU;SAFA;WDWO;;;BA)

:: —— Reregister the BITS files and the Windows Update files ——
call :print Reregister the BITS files and the Windows Update files.

cd /d %SYSTEMROOT%\system32
regsvr32.exe /s atl.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s mshtml.dll
regsvr32.exe /s shdocvw.dll
regsvr32.exe /s browseui.dll
regsvr32.exe /s jscript.dll
regsvr32.exe /s vbscript.dll
regsvr32.exe /s scrrun.dll
regsvr32.exe /s msxml.dll
regsvr32.exe /s msxml3.dll
regsvr32.exe /s msxml6.dll
regsvr32.exe /s actxprxy.dll
regsvr32.exe /s softpub.dll
regsvr32.exe /s wintrust.dll
regsvr32.exe /s dssenh.dll
regsvr32.exe /s rsaenh.dll
regsvr32.exe /s gpkcsp.dll
regsvr32.exe /s sccbase.dll
regsvr32.exe /s slbcsp.dll
regsvr32.exe /s cryptdlg.dll
regsvr32.exe /s oleaut32.dll
regsvr32.exe /s ole32.dll
regsvr32.exe /s shell32.dll
regsvr32.exe /s initpki.dll
regsvr32.exe /s wuapi.dll
regsvr32.exe /s wuaueng.dll
regsvr32.exe /s wuaueng1.dll
regsvr32.exe /s wucltui.dll
regsvr32.exe /s wups.dll
regsvr32.exe /s wups2.dll
regsvr32.exe /s wuweb.dll
regsvr32.exe /s qmgr.dll
regsvr32.exe /s qmgrprxy.dll
regsvr32.exe /s wucltux.dll
regsvr32.exe /s muweb.dll
regsvr32.exe /s wuwebv.dll

:: —— Resetting Winsock ——
call :print Resetting Winsock.
netsh winsock reset

:: —— Resetting WinHTTP Proxy ——
call :print Resetting WinHTTP Proxy.

if %family% EQU 5 (
proxycfg.exe -d
) else (
netsh winhttp reset proxy
)

:: —— Set the startup type as automatic ——
call :print Resetting the services as automatics.
sc.exe config wuauserv start= auto
sc.exe config bits start= delayed-auto
sc.exe config cryptsvc start= auto
sc.exe config TrustedInstaller start= demand
sc.exe config DcomLaunch start= auto

:: —— Starting the Windows Update services ——
call :print Starting the Windows Update services.
net start bits

call :print Starting the Windows Update services.
net start wuauserv

call :print Starting the Windows Update services.
net start appidsvc

call :print Starting the Windows Update services.
net start cryptsvc

call :print Starting the Windows Update services.
net start DcomLaunch

:: —— End process ——
call :print The operation completed successfully.

echo.Press any key to continue . . .
pause>nul
goto :eof
:: /*************************************************************************************/

:: Check and repair errors on the disk.
:: void chkdsk();
:: /*************************************************************************************/
:chkdsk
call :print Check the file system and file system metadata of a volume for logical and physical errors (CHKDSK.exe).

chkdsk %SYSTEMDRIVE% /f /r

if %errorlevel% EQU 0 (
echo.
echo.The operation completed successfully.
) else (
echo.
echo.An error occurred during operation.
)

echo.
echo.Press any key to continue . . .
pause>nul
goto :eof
:: /*************************************************************************************/

:: Scans all protected system files.
:: void sfc();
:: /*************************************************************************************/
:sfc
call :print Scan your system files and to repair missing or corrupted system files (SFC.exe).

if %family% NEQ 5 (
sfc /scannow
) else (
echo.Sorry, this option is not available on this Operative System.
)

if %errorlevel% EQU 0 (
echo.
echo.The operation completed successfully.
) else (
echo.
echo.An error occurred during operation.
)

echo.
echo.Press any key to continue . . .
pause>nul
goto :eof
:: /*************************************************************************************/

:: Scan the image to check for corruption.
:: void dism1();
:: /*************************************************************************************/
:dism1
call :print Scan the image for component store corruption (The DISM /ScanHealth argument).

if %family% EQU 8 (
Dism.exe /Online /Cleanup-Image /ScanHealth
) else if %family% EQU 10 (
Dism.exe /Online /Cleanup-Image /ScanHealth
) else (
echo.Sorry, this option is not available on this Operative System.
)

if %errorlevel% EQU 0 (
echo.
echo.The operation completed successfully.
) else (
echo.
echo.An error occurred during operation.
)

echo.
echo.Press any key to continue . . .
pause>nul
goto :eof
:: /*************************************************************************************/

:: Check the detected corruptions.
:: void dism2();
:: /*************************************************************************************/
:dism2
call :print Check whether the image has been flagged as corrupted by a failed process and whether the corruption can be repaired (The DISM /CheckHealth argument).

if %family% EQU 8 (
Dism.exe /Online /Cleanup-Image /CheckHealth
) else if %family% EQU 10 (
Dism.exe /Online /Cleanup-Image /CheckHealth
) else (
echo.Sorry, this option is not available on this Operative System.
)

if %errorlevel% EQU 0 (
echo.
echo.The operation completed successfully.
) else (
echo.
echo.An error occurred during operation.
)

echo.
echo.Press any key to continue . . .
pause>nul
goto :eof
:: /*************************************************************************************/

:: Repair the Windows image.
:: void dism3();
:: /*************************************************************************************/
:dism3
call :print Scan the image for component store corruption, and then perform repair operations automatically (The DISM /RestoreHealth argument).

if %family% EQU 8 (
Dism.exe /Online /Cleanup-Image /RestoreHealth
) else if %family% EQU 10 (
Dism.exe /Online /Cleanup-Image /RestoreHealth
) else (
echo.Sorry, this option is not available on this Operative System.
)

if %errorlevel% EQU 0 (
echo.
echo.The operation completed successfully.
) else (
echo.
echo.An error occurred during operation.
)

echo.
echo.Press any key to continue . . .
pause>nul
goto :eof
:: /*************************************************************************************/

:: Clean up the superseded components.
:: void dism4();
:: /*************************************************************************************/
:dism4
call :print Clean up the superseded components and reduce the size of the component store (The DISM /StartComponentCleanup argument).

if %family% EQU 8 (
Dism.exe /Online /Cleanup-Image /StartComponentCleanup
) else if %family% EQU 10 (
Dism.exe /Online /Cleanup-Image /StartComponentCleanup
) else (
echo.Sorry, this option is not available on this Operative System.
)

if %errorlevel% EQU 0 (
echo.
echo.The operation completed successfully.
) else (
echo.
echo.An error occurred during operation.
)

echo.
echo.Press any key to continue . . .
pause>nul
goto :eof
:: /*************************************************************************************/

:: Reset Winsock setting.
:: void winsock();
:: /*************************************************************************************/
:winsock
:: —— Reset Winsock control ——
call :print Reset Winsock control.

call :print Restoring transaction logs.
fsutil resource setautoreset true C:\

call :print Restoring TPC/IP.
netsh int ip reset

call :print Restoring Winsock.
netsh winsock reset

call :print Restoring default policy settings.
netsh advfirewall reset

call :print Restoring the DNS cache.
ipconfig /flushdns

call :print Restoring the Proxy.
netsh winhttp reset proxy

:: —— End process ——
call :print The operation completed successfully.

echo.Press any key to continue . . .
pause>nul
goto :eof
:: /*************************************************************************************/

:: End tool.
:: void close();
:: /*************************************************************************************/
:close
exit
goto :eof
:: /*************************************************************************************/
```