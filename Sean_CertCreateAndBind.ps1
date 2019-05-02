$certstore = “cert:\LocalMachine\My”
$cert = New-SelfSignedCertificate –DnsName $env:COMPUTERNAME -CertStoreLocation $certstore
$cert
$certpath = Join-Path -Path $certstore -ChildPath $cert.Thumbprint

if (!(test-path IIS:/SslBindings/0.0.0.0!443)) {
   Push-Location IIS:/SslBindings
   get-item $certpath | new-item '0.0.0.0!443'
   Pop-Location
}