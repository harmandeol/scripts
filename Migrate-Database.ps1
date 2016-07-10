param([string] $ApplicationPath)
$ErrorActionPreference = 'Stop';
$env:PATH="$env:Path;$env:SystemRoot\system32\inetsrv\"
$MigrationsDll = "Prospa.Xero.Database"
function Migrate-Database {
    [CmdletBinding()]
    param
    (
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationPath       
    )

    Write-Output -Message ('Running migrations for : {0}' -f $ApplicationPath);

    try 
    {
        $apiPath = APPCMD list vdirs $ApplicationPath /text:physicalpath
        $binFolder = $apiPath + '\bin'
        $migrateExe = $binFolder + '\migrate.exe'
        $cmd = "$migrateExe $MigrationsDll /startUpDirectory:$binFolder /startUpConfigurationFile:$binFolder\migrate.exe.config"
        Write-Output -Message $cmd
        Invoke-Expression $cmd
    }
    catch 
    {
        throw $_;
    }
}
Migrate-Database $ApplicationPath