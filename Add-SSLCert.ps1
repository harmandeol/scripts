[CmdletBinding()]
param(
    [Parameter(Mandatory=$True,Position=0,HelpMessage="The name of the WebSite, AppPool and URL for the Binding")]
	[string]$Name,
    [Parameter(Mandatory=$True,Position=1,HelpMessage="The IPAddress of the WebSite, AppPool and URL for the Binding")]
	[string]$IPAddress = "*")

$ErrorActionPreference = "Stop";

Import-Module WebAdministration

$sslCertificate = gci 'CERT:\LocalMachine\My' | Where-Object { $_.Subject -ilike "*$Name*" };
if (-not $sslCertificate) {
	Throw "Cannot find SSL certificate for $Name, cannot configure HTTPS... Installed Certificates are:";
	gci CERT:\LocalMachine\My | ft;
}

dir 'IIS:\SslBindings' | Where-Object { $_.IPAddress -eq $ipAddress -and $_.Port -eq 443 } | % { $sslBinding = $_ };

Write-Host "Configuring Website: $Name"

if ($sslBinding) {
	Write-Host "Deleting SslBinding " + $sslBinding;
	Remove-Item -Path "IIS:\SslBindings\$IPAddress!443";
	$sslBinding = $null;
}
New-WebBinding -Name "$Name" -IPAddress $ipAddress -HostHeader "$Name" -Port 443 -Protocol https;
New-Item -Path "IIS:\SslBindings\$IPAddress!443" -Value $sslCertificate;
