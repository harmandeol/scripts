$ErrorActionPreference = "Stop";
$CommonScriptLocation = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)
function Create-Cert {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=0,HelpMessage="Common Name of the certificate")]
        [string]$SUBJ = "/C=AU/ST=NSW/L=Sydney/CN=www.codefac.com.au",
        [Parameter(Mandatory=$False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=1,HelpMessage="FileName to be generated")]
        [string]$FileName = "certificate",
        [Parameter(Mandatory=$False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=1,HelpMessage="Output Folder where files should be generated")]
        [string]$OutputFolder = ".",
        [Parameter(Mandatory=$False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=2,HelpMessage="Private key password")]
        [string]$Password = "Password01",
        [Parameter(Mandatory=$False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=2,HelpMessage="Is it root CA cert?")]
        [bool]$IsCA = $False
    )

    $opensslExe = "C:\Program Files\Git\usr\bin\openssl.exe"
    $AbsoluteFolderPath = (Join-Path $CommonScriptLocation $OutputFolder)
    if(-Not (Test-Path -Path $AbsoluteFolderPath)) {
        New-Item -ItemType Directory -Force -Path $AbsoluteFolderPath
    }
    #remove wildcard from FileName
    $FileName = $FileName -replace '[*.]', ''
    $PrivateKeyPath = (Join-Path $AbsoluteFolderPath "$FileName.key")
    $CertFilePath = (Join-Path $AbsoluteFolderPath "$FileName.pem")

    &$opensslExe genrsa -aes128 -passout pass:$Password -out $PrivateKeyPath 2048
    if( $IsCA -eq $True) {
        &$opensslExe req -x509 -new -nodes -key $PrivateKeyPath -passin pass:$Password -sha256 -days 1024 -out $CertFilePath -subj $SUBJ
    }else {
        &$opensslExe req -new -key $PrivateKeyPath -passin pass:$Password -sha256 -days 1024 -out $CertFilePath -subj $SUBJ
    }
    return new-object psobject -Property @{ Path = $CertFilePath; PrivateKeyPath=$PrivateKeyPath; Password = $Password }
}
