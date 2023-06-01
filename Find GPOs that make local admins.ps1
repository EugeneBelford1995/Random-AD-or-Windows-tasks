$Computers = (Get-ADComputer -Filter * -SearchBase "ou=clients,dc=test,dc=local").Name
ForEach($Computer in $Computers)
{
Invoke-Command -ComputerName $Computer -ScriptBlock {Get-LocalGroupMember -Group "Administrators" | Export-Csv .\LocalAdmins.csv}
}

#$Temp is the SID of the AD group that is added by Group Policy to the specified Local Group
$ErrorActionPreference = 'SilentlyContinue'
$LocalGroup = "S-1-5-32-555"
$GPOfiles = (Get-ChildItem \\test.local\SYSVOL\test.local\Policies\ -Recurse | Select-String "$LocalGroup" -List | Select Path).Path

ForEach($GPOfile in $GPOfiles)
{
$GPOGUID = ($GPOfile.Split("{")[1]).Split("}")[0]
$X = Get-ChildItem \\test.local\SYSVOL\test.local\Policies\ -Recurse | Get-Content | Select-String -Pattern "$LocalGroup"
$Temp = (($X -split("=") | ConvertFrom-String).P2).Replace('*','')
$string = ($Temp | Out-String) ; $GroupSID = $string -replace '\s',''
$ADGroup = (Get-ADGroup -Filter * -Properties * | Where-Object {$_.SID -like "*$GroupSID*"}).CN
Add-Content -Path C:\Users\Public\Documents\GPOs.txt "This is the AD group that's added to the specifid local group via GPO:"
$ADGroup | Out-File C:\Users\Public\Documents\GPOs.txt -Append
Add-Content -Path C:\Users\Public\Documents\GPOs.txt " " 

#Show the GPO that is applying this group
Add-Content -Path C:\Users\Public\Documents\GPOs.txt "This is the GPO's Display Name that is adding the group above to the specified local group:"
$root = (Get-ADDomain).DistinguishedName ; (Get-ADObject -Filter * -SearchBase “cn=policies,cn=system,$root” -Properties * | Where-Object {$_.Name -like "*$GPOGUID*"}).DisplayName | Out-File C:\Users\Public\Documents\GPOs.txt -Append
Add-Content -Path C:\Users\Public\Documents\GPOs.txt " " 
Add-Content -Path C:\Users\Public\Documents\GPOs.txt " --- Next GPO ---  "
Add-Content -Path C:\Users\Public\Documents\GPOs.txt "  "
}