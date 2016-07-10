$ErrorActionPreference = 'Stop';
$CommonScriptLocation = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)
. "$CommonScriptLocation\Create-Cert.ps1"
. "$CommonScriptLocation\Sign-Cert.ps1"

function Create-CASignedCert {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=0, HelpMessage="Common Name of the certificate")]
        [string]$CN = "localhost"
    )

  $OutputFolder = "Certificates"
  $AbsoluteOutputFolderPath = (Join-Path $CommonScriptLocation $OutputFolder)
  $Password = "Password01"

  Create-Cert -SUBJ "/C=AU/ST=NSW/L=Sydney/CN=$CN" -FileName $CN -OutputFolder $OutputFolder  -Password $Password -IsCA $False | `
  Sign-Cert -CAPath (Join-Path $AbsoluteOutputFolderPath "CACert.pem") -CAKeyPath (Join-Path $AbsoluteOutputFolderPath "CACert.key") -CAPassword $Password
}

