$ErrorActionPreference = 'Stop';
$CommonScriptLocation = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)
. "$CommonScriptLocation\Remove-Host.ps1"

$filename = "C:\Windows\System32\drivers\etc\hosts"

function Add-Host([string]$ip, [string]$hostname) {
	Remove-host $filename $hostname
	$ip + "`t`t" + $hostname | Out-File -encoding ASCII -append $filename
}