$ErrorActionPreference = 'Stop';
$CommonScriptLocation = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)
. "$CommonScriptLocation\Create-CASignedCert.ps1"
. "$CommonScriptLocation\Install-Cert.ps1"
. "$CommonScriptLocation\Set-CertificatePermission.ps1"
. "$CommonScriptLocation\Create-Website.ps1"

function Create-SSLWebsite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=0, HelpMessage="Website Name")]
        [string]$Website,
        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=1, HelpMessage="Certificate common name starts with")]
        [string]$CN,
        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=2, HelpMessage="Physical Path")]
        [string]$PhysicalPath
    )
    $Certificate = ( dir cert:\LocalMachine\My\ | ? { $_.subject -like "CN=$CN*" } | Select -First 1 )

    if(-Not [bool]$Certificate) {
      Write-Host "creating a certificate with common name `"$CN`""
      Create-CASignedCert -CN $CN |  Install-Cert -CertStore My
      $Certificate = ( dir cert:\LocalMachine\My\ | ? { $_.subject -like "CN=$CN*" } | Select -First 1 )
    } else {
      Write-Host "Certificate is already installed with CommonName `"$CN`"";
	  $Certificate;
    }

    Create-Website -Website         $Website `
                   -AppPoolName     $Website `
                   -PhysicalPath    $PhysicalPath `
                   -SslCertificate  $Certificate

    #| Set-CertificatePermission -ServiceAccount "IIS AppPool\$Website"
}
