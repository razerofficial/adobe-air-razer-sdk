CALL init.cmd
rm -r -f %PROJNAME%New
MOVE %PROJNAME% %PROJNAME%New
IF NOT EXIST ..\CopyUniqueAppVersionId\bin\Debug\CopyUniqueAppVersionId.exe ECHO Be sure to build the build tool to copy the unique app version id
IF NOT EXIST ..\CopyUniqueAppVersionId\bin\Debug\CopyUniqueAppVersionId.exe PAUSE
..\CopyUniqueAppVersionId\bin\Debug\CopyUniqueAppVersionId.exe %PROJNAME%New\AndroidManifest.xml AndroidManifest.xml
COPY /Y AndroidManifest.xml %PROJNAME%New\AndroidManifest.xml
COPY /Y icons\leanback_icon.png %PROJNAME%New\res\drawable
IF EXIST %PROJNAME%New.apk DEL %PROJNAME%New.apk
"%JDK7%\bin\java.exe" -jar %APKTOOL% build %PROJNAME%New %PROJNAME%New.apk
IF EXIST %PROJNAME%New\dist\%PROJNAME%.apk COPY %PROJNAME%New\dist\%PROJNAME%.apk %PROJNAME%New.apk
if NOT "%NO_PAUSE%"=="true" PAUSE
