$Cred = Get-Credential
Stop-Computer -ComputerName <insert Computernames> -Force -Confirm:$false -Credential $Cred