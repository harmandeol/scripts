$ErrorActionPreference = "Stop";
function Sign-Cert {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=0, HelpMessage="File path of certificate")]
        [string]$Path,

        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=1, HelpMessage="File path of certificate private key")]
        [string]$PrivateKeyPath,

        [Parameter(Mandatory=$false, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=2, HelpMessage="Password of certificate")]
        [ValidateNotNullOrEmpty()]
        [string]$Password,

        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=3, HelpMessage="File path of CAcertificate")]
        [ValidateNotNullOrEmpty()]
        [string]$CAPath,

        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=4, HelpMessage="File path of CAcertificate Key")]
        [ValidateNotNullOrEmpty()]
        [string]$CAKeyPath,

        [Parameter(Mandatory=$false, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Position=5, HelpMessage="Password of CA certificate")]
        [ValidateNotNullOrEmpty()]
        [string]$CAPassword
        )

    $CertBasePath = $Path.Substring(0, $Path.LastIndexOf('.'))
    $CertPathPfx = "$CertBasePath.pfx"
    #$CertPathCrt = "$CertBasePath.crt"

    $opensslExe = "C:\Program Files\Git\usr\bin\openssl.exe"

    &$opensslExe x509 -req -in $Path -passin pass:$Password -CA $CAPath -CAkey $CAKeyPath -passin pass:$CAPassword -CAcreateserial -out $Path -days 500 -sha256

    &$opensslExe pkcs12 -export -out $CertPathPfx -passout pass:$Password -inkey $PrivateKeyPath -passin pass:$Password -in $Path

    return new-object psobject -Property @{Path =  $CertPathPfx; Password = $Password }
}