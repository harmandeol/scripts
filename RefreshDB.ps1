param(
    [parameter(Mandatory=$false)]
    [string] $ServerInstance = $env:COMPUTERNAME    
)

$scriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sqlDir  = Join-Path $scriptsDir "Sql"

try {
    Push-Location $scriptsDir
    Import-Module SQLPS -DisableNameChecking

    foreach ($f in Get-ChildItem -path $sqlDir -Filter *.sql | sort-object -desc ) 
    { 
        & sqlcmd -S $ServerInstance -E -i $f.fullname    
    }
}
finally {
    Pop-Location
}
