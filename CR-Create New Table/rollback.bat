@ECHO OFF
SETLOCAL

ECHO Now rollback the changes ...

SET FILE_NAME=Create_Customer_Table_ROLLBACK
sqlcmd -E -S "%~1" -i ".\rollback\%FILE_NAME%.sql" > ".\logs\%FILE_NAME%.log"
ECHO Database changes has been rollbacked

ENDLOCAL