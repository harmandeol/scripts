if OBJECT_ID('tempdb..#Users') is not null
drop table #Users 

create table #Users 
(
    LoginName NVARCHAR(50), 
    UserName NVARCHAR(50),
    DatabaseName NVARCHAR(50)   
)

Insert Into #Users (LoginName, UserName, DatabaseName)
Values
	('IIS APPPOOL\cellarmasters.localhost', 'cellarmasters_localhost', 'Cellarmasters')



DECLARE @cmd NVARCHAR(MAX);
SET @cmd = '';

DECLARE cur CURSOR LOCAL FORWARD_ONLY
FOR 
SELECT 'USE ' + u.DatabaseName + ';

IF NOT EXISTS 
(
     SELECT 1 
     FROM sys.database_principals dp 
     WHERE dp.name = ''' + u.UserName + '''
)
BEGIN 
	IF NOT EXISTS (SELECT * FROM master.sys.server_principals WHERE name = N'''+ u.LoginName+''')   
    BEGIN
		CREATE LOGIN ' + QUOTENAME(u.LoginName) + '  FROM WINDOWS;
	END
    
	CREATE USER ' + QUOTENAME(u.UserName) + ' 
    FROM LOGIN ' + QUOTENAME(u.LoginName) + '
        WITH DEFAULT_SCHEMA = dbo;
END
EXEC sp_addrolemember @RoleName = ''db_datareader''
    , @MemberName = ''' + u.UserName + ''';

'
FROM #Users u


OPEN cur;
FETCH NEXT FROM cur 
INTO @cmd;

WHILE @@FETCH_STATUS = 0
BEGIN

    PRINT (@cmd);
	EXEC (@cmd);

    FETCH NEXT FROM cur 
    INTO @cmd;
END

CLOSE cur;
DEALLOCATE cur;