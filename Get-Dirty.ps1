Function Get-Dirty
{
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$DirtyWordPath, # Rename to avoid confusion with the list itself
        [Parameter(Mandatory=$true, Position=1)]
        [string]$LogPath
    )
    $ErrorActionPreference = "SilentlyContinue"

    # 1. Load the list from the path provided in the parameter
    $DirtyWordList = Get-Content $DirtyWordPath

    # 2. Search all transcripts
    # We return the result of the entire loop to the pipeline
    $Results = Get-ChildItem -Path "$LogPath\*.txt" -Recurse | ForEach-Object {
        $CurrentFile = $_
        $Matches = Select-String -Path $CurrentFile.FullName -Pattern $DirtyWordList -Context 0,0
        $FileContent = Get-Content $CurrentFile
        #$Username = ($FileContent[3] -replace 'Username: ', '').Trim()
        $Username = $FileContent[3]

        if ($Matches -and $Username -notlike "*SYSTEM") {
            $FileContent = Get-Content $CurrentFile.FullName
            $UserLine    = $FileContent[3] 
            $HostLine    = (($FileContent[6]).Split(":")[1]).Split(" ")[1] 
            $StartTime   = $FileContent[2] # Start time is usually line 2 (Index 1)

            foreach ($Match in $Matches) {
                [PSCustomObject]@{
                    Timestamp  = ($StartTime).Split(':', 2)[1].Trim()
                    User       = ($UserLine -replace 'Username: ', '').Trim()
                    Computer   = ($HostLine -replace 'Computer: ', '').Trim()
                    DirtyWord  = $Match.Pattern
                    Command    = $Match.Line.Trim()
                    LogFile    = $CurrentFile.Name
                }
            }
        }
    }
    
    # Send the final collection to the function output
    return $Results
}

# --- How to run it now ---
Write-Host "Example command to use this function: Get-Dirty -DirtyWordPath "C:\DirtyWords.txt" -LogPath "C:\PS_Logs" | Format-Table -AutoSize"
Write-Host "Use | Out-GridView instead of | Format-Table -Autosize IOT get output you can sort by time."


Function Get-Clean
{
Param
    (
        [Parameter(Mandatory=$true, Position=1)]
        [string]$LogPath
    )
$ErrorActionPreference = "SilentlyContinue"

$Results = Get-ChildItem -Path "$LogPath\*.txt" -Recurse | ForEach-Object {
$CurrentFile = $_
$FileContent = Get-Content $CurrentFile
$Username = $FileContent[3].Split("\")[1]
$DA_Admins = (Get-ADGroupMember "Domain Admins").SamAccountName
$Matches = $DA_Admins -notcontains $Username

#-and ($Username -notlike "*SYSTEM")
If($Matches -and $Username -notlike "*SYSTEM")
{
$FileContent = Get-Content $CurrentFile
$UserLine    = $FileContent[3] 
$HostLine    = (($FileContent[6]).Split(":")[1]).Split(" ")[1]
$StartTime   = $FileContent[2] # Start time is usually line 2 (Index 1)

foreach ($Match in $Matches){
[PSCustomObject]@{
Timestamp  = ($StartTime).Split(':', 2)[1].Trim()
User       = ($UserLine -replace 'Username: ', '').Trim()
Computer   = ($HostLine -replace 'Computer: ', '').Trim()
LogFile    = $CurrentFile
} #Close the PSCustomObject
} #Close the ForEach
} #Close the If

} #| Format-Table -AutoSize #Close the ForEach-Object
return $Results
} #Close the Function
