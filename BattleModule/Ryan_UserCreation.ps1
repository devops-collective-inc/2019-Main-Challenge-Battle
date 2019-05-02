function CreateIisUsersAndAddToLocalGroup
{
   $hackPassword = ConvertTo-SecureString -String 'someStuffToWorkHere123' -AsPlainText -Force
   New-LocalGroup -Name 'IisAdmins'
   New-LocalUser -Name 'IisUser' -AccountNeverExpires -FullName 'IIS User Account' -Password $hackPassword
   New-LocalUser -Name 'IisAdmin' -AccountNeverExpires -FullName  'IIS Admin Account' -Password $hackPassword
   Add-LocalGroupMember -Group 'IisAdmins' -Member 'IisAdmin'
}

CreateIisUsersAndAddToLocalGroup