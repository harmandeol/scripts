$ErrorActionPreference = 'Stop';

function Install-Cert {
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string]$Path,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,

        [Parameter(Position=2, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$CertStore
    )

    Write-Verbose -Message ('Installing certificate from path: {0}' -f $Path);

    try
    {
        # Create the certificate
        $pfxcert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ErrorAction Stop;
        $KeyStorageFlags = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable -bxor [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet -bxor [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet;
        Write-Verbose ('Key storage flags is: {0}' -f $KeyStorageFlags);

        $pfxcert.Import($Path, (ConvertTo-SecureString $Password -AsPlainText -Force), $KeyStorageFlags);

        # Create the X509 store and import the certificate
        $store = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $CertStore, LocalMachine -ErrorAction Stop;
        $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite);
        $store.Add($pfxcert);
        $store.Close();

        Write-Output -InputObject $pfxcert;   
    }
    catch
    {
        throw $_;
    }
}