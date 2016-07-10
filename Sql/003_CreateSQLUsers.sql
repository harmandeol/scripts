if OBJECT_ID('tempdb..#Users') is not null
drop table #Users 

create table #Users 
(
    LoginName NVARCHAR(50), 
    Password NVARCHAR(50),
    DatabaseName NVARCHAR(50)   
)

Insert Into #Users (LoginName, Password, DatabaseName)
Values
	('someuser', 'something', 'Cellarmasters')


DECLARE @cmd NVARCHAR(MAX);
SET @cmd = '';

DECLARE cur CURSOR LOCAL FORWARD_ONLY
FOR 
SELECT 'USE ' + u.DatabaseName + ';

IF NOT EXISTS 
(
     SELECT 1 
     FROM sys.database_principals dp 
     WHERE dp.name = ''' + u.LoginName + '''
)
BEGIN 
	IF NOT EXISTS (SELECT * FROM master.sys.server_principals WHERE name = N'''+ u.LoginName+''')   
    BEGIN
		CREATE LOGIN ' + QUOTENAME(u.LoginName) + '  WITH PASSWORD = N'''+ u.Password+''', CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
	END
    
	CREATE USER ' + QUOTENAME(u.LoginName) + ' 
    FROM LOGIN ' + QUOTENAME(u.LoginName) + '
        WITH DEFAULT_SCHEMA = dbo;
END
EXEC sp_addrolemember @RoleName = ''db_datareader''
    , @MemberName = ''' + u.LoginName + ''';

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