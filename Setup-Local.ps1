$ErrorActionPreference = 'Stop';
$CommonScriptLocation = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)
. "$CommonScriptLocation\Create-SSLWebsite.ps1"
. "$CommonScriptLocation\Add-Host.ps1"

$WebsiteConfigurationArray =   @([pscustomobject]@{Website="cellarmasters.localhost"; RelativePath="..\Presentation\Web\Cell.Web"},
                                [pscustomobject]@{Website="nzwinesociety.localhost"; RelativePath="..\Presentation\Web\NZ.Web"}
                                [pscustomobject]@{Website="paypal.localhost"; RelativePath="..\Presentation\Web\Paypal"}
                                [pscustomobject]@{Website="admin.localhost"; RelativePath=".\Presentation\Web\Cell.admin"});

$WebsiteConfigurationArray | foreach {
    Add-Host -ip '127.0.0.1' -hostname $_.Website
    $PhysicalPath = Join-Path $CommonScriptLocation  $_.RelativePath
    $PhysicalPath = [System.IO.Path]::GetFullPath($PhysicalPath)
	Create-SSLWebsite -Website $_.Website -CN "*.localhost" -PhysicalPath $PhysicalPath
}              
