SET JAVA_HOME=C:\NVPACK\jdk1.7.0_71
REM SET JAVA_HOME=c:\Program Files\Java\jdk1.8.0_73
SET PATH=%JAVA_HOME%\bin;%PATH%
SET JAR="%JAVA_HOME%\bin\jar.exe"

SET AIR_SDK=C:\Program Files\Adobe\Adobe Animate CC 2015.2\AIR21.0

IF NOT EXIST %AIR_SDK% ECHO AdobeAIRSDK was not found!
IF NOT EXIST %AIR_SDK% PAUSE
IF NOT EXIST %AIR_SDK% EXIT

REM path to the ADT tool in Flash Builder sdks
SET ADT=%AIR_SDK%\bin\adt.bat

REM name of ANE file
SET ANE_NAME=RazerSDKNativeExtension.ane

REM AS lib folder
SET LIB_FOLDER=lib

SET TEMP=temp

SET COMBINED_JAR=AirRazerSDKPlugin.jar

REM grab the extension descriptor and SWC library 
echo on

rm -r -f %TEMP%
IF NOT EXIST %TEMP% md %TEMP%
IF NOT EXIST %TEMP%\ane md %TEMP%\ane
IF NOT EXIST %TEMP%\ane\Android-ARM md %TEMP%\ane\Android-ARM

COPY %LIB_FOLDER%\src\extension.xml %TEMP%\ane
COPY %LIB_FOLDER%\bin\*.swc %TEMP%\ane
CD %TEMP%\ane\
%JAR% xf *.swc
MOVE library.swf Android-ARM
cd ..\..\

echo Combine AARs/JARs into a JAR supported by the AIR Compiler
cd jar
rm -r -f tmp
mkdir tmp
cd tmp
PWD
IF EXIST ../%TEMP%/ane/Android-ARM/%COMBINED_JAR% DEL ../%TEMP%/ane/Android-ARM/%COMBINED_JAR%
IF EXIST classes.jar DEL classes.jar
CALL %JAR% -xvf ../AirRazerSDKPlugin/java/libs/store-sdk-standard-release.aar classes.jar
RENAME classes.jar temp.jar
CALL %JAR% -xvf temp.jar
DEL temp.jar
IF EXIST classes.jar DEL classes.jar
rm -r -f jni
CALL %JAR% -xvf ../AirRazerSDKPlugin/java/build/outputs/aar/java-release.aar jni
IF NOT EXIST ../%TEMP%/ane/Android-ARM/armeabi-v7a MKDIR ..\%TEMP%\ane\Android-ARM\armeabi-v7a
COPY /Y jni\armeabi-v7a\lib-ouya-ndk.so ..\%TEMP%\ane\Android-ARM\armeabi-v7a
rm -r -f jni
CALL %JAR% -xvf ../AirRazerSDKPlugin/java/build/outputs/aar/java-release.aar classes.jar
RENAME classes.jar temp.jar
CALL %JAR% -xvf temp.jar
DEL temp.jar
RENAME classes.jar temp.jar
CALL %JAR% -xvf temp.jar
DEL temp.jar
CALL %JAR% -cvf ../%TEMP%/ane/Android-ARM/%COMBINED_JAR% .
cd ..

DIR %TEMP%\ane\extension.xml
DIR %TEMP%\ane\*.swc
DIR %TEMP%\ane\Android-ARM

CALL "%ADT%" -package -storetype PKCS12 -keystore cert.p12 -storepass password -tsa none -target ane %ANE_NAME% %TEMP%\ane\extension.xml -swc %TEMP%\ane\*.swc  -platform Android-ARM -C %TEMP%\ane\Android-ARM .
		
if NOT "%NO_PAUSE%"=="true" PAUSE
