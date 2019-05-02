$scriptPath = Split-Path $MyInvocation.MyCommand.Path
#region Load Private Functions
try
{
	Get-ChildItem "$scriptPath" -filter *.ps1 | Select-Object -ExpandProperty FullName | ForEach-Object{
		. $_
	}
}
catch
{
	Write-Warning "There was an error loading $($function) and the error is $($psitem.tostring())"
	exit
}
