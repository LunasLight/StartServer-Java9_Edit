@ECHO OFF

REM For testing the Bat aspects of this file (It doesn't load java when true)
SET BAT_TEST=FALSE

REM If the server should auto restart. False is how it functions currently, True along with COUNTDOWN_ENABLED=TRUE would mean parity with startserver-java9.sh
SET AUTO_RESTART=FALSE

REM If there should be a countdown to either start or stop the server. COUNTDOWN_ENABLED being set to true with AUTO_RESTART set to false will shut down the server after COUNTDOWN_TIMER seconds but still manually have the option to restart instead.
SET COUNTDOWN_ENABLED=FALSE

REM How long the timer should be for the countdown to start or stop the server.
SET COUNTDOWN_TIMER=15

REM The path to the java you would like to use surrounded in quotations
REM !! IMPORTANT !! If you copy paste your java from Prism Launcher's download make sure to change javaw.exe to java.exe
REM E.G: SET CUSTOM_JAVA="G:/Games/PrismLauncher/java/eclipse_temurin_jre26.0.2+10/bin/java.exe"
SET CUSTOM_JAVA_VERSION=

IF NOT DEFINED CUSTOM_JAVA_VERSION (
	SET CUSTOM_JAVA_VERSION=java
)
	
IF NOT EXIST "User_Java_Args.txt" (
	(	
	ECHO -Xms6144M
	ECHO -Xmx6144M
	ECHO -Dfml.readTimeout=180
	ECHO -Duser.language=en
	)> "User_Java_Args.txt"
)

:SERVER_START
ECHO Don't forget to accept the EULA or it won't boot && ECHO:
ECHO Add this argument behind the other "-Dfml..." in User_Java_Args.txt to silently migrate your world during startup, a backup will be created: -Dfml.queryResult=confirm
ECHO:

IF %BAT_TEST% == FALSE (
	@ECHO ON 
	%CUSTOM_JAVA_VERSION% ^
	@User_Java_Args.txt ^
	@java9args.txt ^
	-jar lwjgl3ify-forgePatches.jar ^
	nogui
)

@ECHO OFF
IF %COUNTDOWN_ENABLED% == TRUE (
	ECHO:
	FOR /L %%i IN (%COUNTDOWN_TIMER% -1 1) DO (
		SETLOCAL enableextensions enabledelayedexpansion
		FOR /F %%a IN ('copy /Z "%~dpf0" nul') DO SET "CR=%%a"
		IF %AUTO_RESTART% == TRUE (
			SET BUFFER=Restarting Server in : %%i Seconds. [S]top Now, [R]estart Now 
			< NUL SET /P "=Restarting Server in : %%i Seconds. [S]top Now, [R]estart Now !CR!"
		) ELSE (
			SET BUFFER=Stopping Server in : %%i Seconds. [S]top Now, [R]estart Now
			< NUL SET /P "=Stopping Server in : %%i Seconds. [S]top Now, [R]estart Now !CR!"
		)
		FOR /F "Delims=" %%G IN ('Choice /T 1 /N /C:CSRW /D W') DO (
			IF %%G == S GOTO :SERVER_STOP
			IF %%G == R CLS && GOTO :SERVER_START
		)
	)
)

IF %AUTO_RESTART% == TRUE (
	GOTO :SERVER_START
) ELSE (
	GOTO :SERVER_STOP
)

:SERVER_STOP
ECHO %BUFFER% && ECHO: && ECHO Server Stopped.
@PAUSE > NUL
