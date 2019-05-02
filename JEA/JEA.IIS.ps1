$zPSSession=New-PSSession -ComputerName . -ConfigurationName JEA.IIS
Import-PSSession -Session $zPSSession -WarningAction SilentlyContinue -Prefix JeaIIS

