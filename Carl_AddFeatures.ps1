

Install-WindowsFeature "Web-Server","Windows-Internal-DB","NLB" -includemanagementtools

Uninstall-windowsfeature "Powershell-v2" -remove