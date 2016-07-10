$ErrorActionPreference = 'Stop';
$CommonScriptLocation = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)
. "$CommonScriptLocation\Install-Cert.ps1"

$OutputFolder = "Certificates"
$AbsoluteOutputFolderPath = (Join-Path $CommonScriptLocation $OutputFolder)

Install-Cert (Join-Path $AbsoluteOutputFolderPath "CACert.pem") -Password "Password01" -CertStore Root