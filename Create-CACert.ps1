$ErrorActionPreference = 'Stop';
$CommonScriptLocation = (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)
. "$CommonScriptLocation\Create-Cert.ps1"

Create-Cert -SUBJ "/C=AU/ST=NSW/L=Sydney/CN=www.codefac.com.au" -FileName CACert -OutputFolder Certificates -Password Password01 -IsCA $True