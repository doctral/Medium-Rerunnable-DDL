@ECHO OFF
SETLOCAL

ECHO Now deploy the changes ...

SET FILE_NAME=Create_Customer_Table
sqlcmd -E -S "%~1" -i ".\deploy\%FILE_NAME%.sql" > ".\logs\%FILE_NAME%.log"
ECHO Datatable has been created

ENDLOCAL
