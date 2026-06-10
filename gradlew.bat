@echo off
setlocal

set DEFAULT_JVM_OPTS=-Xmx1g
set APP_NAME=Gradle
set APP_BASE_NAME=%~n0
set DIRNAME=%~dp0
set CLASSPATH=%DIRNAME%gradle\wrapper\gradle-wrapper.jar

"%JAVA_HOME%\bin\java" %DEFAULT_JVM_OPTS% -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*
