:: author - Thomas Underwood
:: date   - 2020/03/15
:: call readvers.bat, which reads vers.php in this directory
:: this is then used to create a tag under that version number
:: tag.bat 2020 © Thomas Underwood

@ECHO off
:: default address protocol
SET filep=file:///
:: default repo address
SET repo=%filep%D:/SVN/get_vers
:: default version file is in same directory as this script
SET versf=vers.php
:: command line args for svn, -m must be immediately before user input %message%
SET args=-m

:: tell user what this does
ECHO ******************************************************
ECHO * This script will create a tagged version from your *
ECHO * trunk. You can optionally input a log message and  *
ECHO * provide your own tag name. You do not need to      * 
ECHO * include the trunk directory in the repo path.      *
ECHO ******************************************************

:: check IF repo address is dIFferent from default
SET overriderepo=""
ECHO.
ECHO IF you do not want to use %repo% as your repo address, 
ECHO enter your own now. E.G. svn://myrepo/myproj 
ECHO Otherwise press return:
SET /p overriderepo="" 
IF %overriderepo% NEQ "" SET repo=%overriderepo%
SET tags_dir=%repo%/tags

:: adds the user's message to args
ECHO.
ECHO Enter the log message for version control:
SET /p message="" 
SET args="%args% %message%"

:: call readvers to put version in a txt file, %versf% is where to look
CALL :readvers %versf%

:: find the line and put in vers
FOR /F "delims=" %%a in (temp_version.txt) DO SET vers=%%a

:: tell the user the message they input so they can confirm it
ECHO.
ECHO Log message: %message%

:: offer to override the version with user input
SET overridevers=""
ECHO.
ECHO IF you do not want to use the tag name %vers%, 
ECHO enter your own now. Otherwise press return:
SET /p overridevers=""
IF %overridevers% NEQ "" SET vers=%overridevers%

:: confirm user wants to do it
SET dest=%tags_dir%/%vers%
ECHO.
ECHO Do you want to create the tag in %dest%, Y/N ?
SET /p continue=""
IF %continue% == y (
    GOTO docopy
) ELSE IF %continue == Y (
    GOTO docopy
) ELSE (
    GOTO doend
)

:: copy the dir to a new one, with the name given
:docopy
ECHO.
ECHO Creating %dest%..
svn copy %args% %repo%/trunk %dest%
GOTO finish

:: tell user didn't do the tag and go to end
:doend
ECHO.
ECHO Did not tag anything.
GOTO finish

:: read version from a file
:readvers
SETLOCAL EnableDelayedExpansion
:: expects verion file to be vers.php by default
SET versfile=%1
:: find the line that doesn't have a ? and put it in text.txt
ECHO Detecting version number in %versfile%..
FOR /F "delims=" %%a in ('findstr /v "?" %versfile% ') DO SET var=%%a
:: remove the $vers
SET newvar=!var:$vers=!
:: remove the whitespace
SET newvar=!newvar: =! 
:: echo what we have into the temp file
ECHO !newvar! > temp1.txt
:: hide the temp file
ATTRIB +H temp1.txt
:: read the file using = as a delimeter to remove it
FOR /F "delims==;" %%b in (temp1.txt) DO SET endvar=%%b
:: endvar is now version number, output to version.txt
ECHO !endvar! > temp_version.txt
:: hide the temp file
ATTRIB +H temp_version.txt
:: tidy up, unhide temp file first
ATTRIB -H temp1.txt
DEL temp1.txt
:: return to where this sr was called
EXIT /B

:: tidy up and end, unhide temp file first
:finish
ECHO.
ATTRIB -H temp_version.txt
DEL temp_version.txt
ECHO Finished.
ECHO You will need to update the %tags_dir% directory, to see this change locally.
PAUSE
EXIT