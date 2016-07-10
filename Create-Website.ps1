
$ErrorActionPreference = 'Stop';
$CommonScriptLocation = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

$iisAppPoolDotNetVersion = "v4.0"

function Create-Website {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=0, HelpMessage="Website Name")]
        [string]$Website,
        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=1, HelpMessage="App pool name")]
        [string]$AppPoolName,
        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=2, HelpMessage="Physical Path")]
        [string]$PhysicalPath,
        [Parameter(Mandatory=$False,Position=3,HelpMessage="The IPAddress of the WebSite, AppPool and URL for the Binding")]
	    [string]$IPAddress = "*",
        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=4, HelpMessage="SslCertificate")]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$SslCertificate
    )
    Import-Module WebAdministration
    $ipAddress = "0.0.0.0"
    if($IPAddress -ne "*"){
        $ipAddress = $IPAddress
    }

    Push-Location -Path $CommonScriptLocation
    Try
    {
        cd IIS:\AppPools\
        if (!(Test-Path $AppPoolName -pathType container))
        {
            $appPool = New-Item $AppPoolName
            $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
        }

        cd IIS:\Sites\

        if (Test-Path $Website -pathType container)
        {
            Write-Host "Deleting Website " + $Website;
            Remove-Website $Website ;
        }

        $iisApp = New-Item "$Website" -bindings @{protocol='http'; bindingInformation=':80:' + $Website } -physicalPath "$PhysicalPath"
        $iisApp | Set-ItemProperty -Name "applicationPool" -Value $AppPoolName

        cd IIS:\SslBindings\

        Write-Host "Configuring Website: $Website"
        $sslBinding = (dir IIS:\SslBindings\ | Where-Object { $_.IPAddress -eq "$ipAddress" -and $_.Port -eq 443 })

        $IPAddress_Port = "$ipAddress!443"

        if ($sslBinding) {
            Write-Host "Deleting SslBinding " + $sslBinding;
            Remove-Item -Path $IPAddress_Port;
            $sslBinding = $null;
        }

        New-WebBinding -Name "$Website" -HostHeader "$Website" -Port 443 -Protocol https #-SslFlags 1; --find alternative for PSVersion 4
        $SslCertificate | New-Item -Path $IPAddress_Port
    }
    Finally
    {
        Pop-Location
    }
}

