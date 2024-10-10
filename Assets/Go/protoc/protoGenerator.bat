@echo off
REM This batch file generates Go code from the Protobuf definition

REM Display current directory
echo Current directory: %CD%

REM Run protoc command
echo Generating Go code from Protobuf...
::protoc --csharp_out="D:\Unity Projects\GoTcpTest\Assets\Scripts" *.proto
::protoc --go_out=../../ *.proto
protoc --csharp_out="D:\Unity\TeamProject\fallguys\Assets\Scripts\GoTCP" *.proto
protoc --go_out=../../ *.proto



REM Check if the command was successful
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to generate Go code.
    exit /b 1
)

echo Go code generation completed successfully.

REM Pause to keep the command window open (optional)