New-Item `
    -ItemType Directory `
    -Path C:\ProgramData\JEA.IIS
Copy-Item -Path $PSScriptRoot\* -Destination C:\ProgramData\JEA.IIS
$SddlString="O:NSG:BAD:P(A;;GX;;;$((Get-LocalGroup -Name test).sid.value))S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)"
Register-PSSessionConfiguration `
    -Name JEA.IIS `
    -Path C:\ProgramData\JEA.IIS\JEA.IIS.pssc `
    -SecurityDescriptorSddl $SddlString
    