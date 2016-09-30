SET JAVA_HOME=C:\NVPACK\jdk1.7.0_71
CALL gradlew clean build
if NOT "%NO_PAUSE%"=="true" PAUSE
