
<#PSScriptInfo

.VERSION 1.3.4

.GUID 2fdbeea1-7642-44e3-9c0c-258631425e36

.AUTHOR Edward van Biljon and modified by Sam Drey

.COMPANYNAME

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

#>

<# 

.DESCRIPTION 
    Script adapted from Edward van Biljon https://gallery.technet.microsoft.com/office/Clear-Exchange-2013-Log-71abba44
    Added bells ans whistles, getting Exchange Logging directories from environment variables, added progress bars,
    options for the -Days back, the -DoNotDelete options to just list the files size, the dialog boxes to confirm
    continue with the script Y/N, and the -NoConfirmation switch to bypass the confirmation dialog boxes to use the 
    script on Windows Scheduled task.

.EXAMPLE
    .\CleanExchangeLogFiles.ps1 -Days 5 -DoNotDelete
    Will just display the folders and the total size for each folder that we may want to delete

.EXAMPLE
    .\CleanExchangeLogFiles.ps1 -Days 30
    Will display the folders, and delete all files older than 30 days in the IIS folder and Exchange Logging directories

.EXAMPLE
    .\CleanExchangeLogFiles.ps1 -Days 30 -NoConfirmation
    To be used in Windows Scheduled tasks only as it doesn't provide user confirmation to delete files or cancel script.

.LINK
    https://gallery.technet.microsoft.com/office/Clear-Exchange-2013-Log-71abba44
    https://github.com/SammyKrosoft/Clean-Exchange-Log-Files

#>
[CmdletBinding(DefaultParameterSetName="Exec")]
Param(
    [Parameter(Mandatory = $false,ParameterSetName="Exec")][int]$Days=5,
    [Parameter(Mandatory = $false, ParameterSetName="Exec")][switch]$DoNotDelete,
    [Parameter(Mandatory = $false, ParameterSetName="Exec")][switch]$DeleteLodCTRBackup,
    [Parameter(Mandatory = $false)][switch]$NoConfirmation,
    [Parameter(Mandatory = $false,ParameterSetName="Check")][switch]$CheckVersion
    
)
<# ------- SCRIPT_HEADER (Only Get-Help comments and Param() above this point) ------- #>
#Initializing a $Stopwatch variable to use to measure script execution
$stopwatch = [system.diagnostics.stopwatch]::StartNew()
#Using Write-Debug and playing with $DebugPreference -> "Continue" will output whatever you put on Write-Debug "Your text/values"
# and "SilentlyContinue" will output nothing on Write-Debug "Your text/values"
$DebugPreference = "Continue"
# Set Error Action to your needs
$ErrorActionPreference = "SilentlyContinue"
#Script Version
$ScriptVersion = "1.3.3"
<# Version changes
v1.3.4 : added DeleteLodCTRBackup switch
v1.3.3 : fixed issue where copy/paste text from script was messed up in Notepad.exe
v1.3.2 : changed color of folders display (was yellow on cyan, now is dark red on cyan)
v1.3.1 : renamed the script from CleanExchangeLogs.ps1 to CleanExchangeLogFiles.ps1 and added examples and completed description
v1.3   : added -NoConfirmation switch to bypass the confirmation dialog box.
v1.2.4 : update note with no update: script was NOT broken... GitHub Releases made downloads strip line feed/carriage return.
v1.2.3 : fixed broken script (sorry about that)
v1.2.2 : adapted Message Box title and message if we Read Only files or if we Delete files
v1.2.1 : rephrasing, removed display file size in KB (keeping MB and GB only)
v1.2 : added -DoNotDelete switch, to dump file size only without deleting
v1.1 : fixed Logging function didn't trigger when in Cleanup function
V1 : added $Day or -Day parameter, default 5 days ago, added logging function, progress bars, ...
v0.1 : first script version
#>

$ScriptName = $MyInvocation.MyCommand.Name
If ($CheckVersion) {Write-Host "SCRIPT NAME     : $ScriptName `nSCRIPT VERSION  : $ScriptVersion";exit}
# Log or report file definition
$UserDocumentsFolder = "$($env:USERPROFILE)\Documents"
$OutputReport = "$UserDocumentsFolder\$($ScriptName)_Output_$(get-date -f yyyy-MM-dd-hh-mm-ss).csv"
# Other Option for Log or report file definition (use one of these)
$ScriptLog = "$UserDocumentsFolder\$($ScriptName)_Logging_$(Get-Date -Format 'dd-MMMM-yyyy-hh-mm-ss-tt').txt"
<# ---------------------------- /SCRIPT_HEADER ---------------------------- #>

    #Checks if the user is in the administrator group. Warns and stops if the user is not.
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "You are not running this as local administrator. Run it again in an elevated prompt." -BackgroundColor Red; exit
}

Set-Executionpolicy RemoteSigned
#$days=5 defining 

#region Functions

Function MsgBox {
    [CmdletBinding()]
    Param(
        [Parameter(Position=0)][String]$msg = "Do you want to continue ?",
        [Parameter(Position=1)][String]$Title = "Question...",
        [Parameter(Position=2)]
            [ValidateSet("OK","OKCancel","YesNo","YesNoCancel")]
                [String]$Button = "YesNo",
        [Parameter(Position=3)]
            [ValidateSet("Asterisk","Error","Exclamation","Hand","Information","None","Question","Stop","Warning")]
                [String]$Icon = "Question"
    )
    Add-Type -AssemblyName presentationframework, presentationcore
    [System.Windows.MessageBox]::Show($msg,$Title, $Button, $icon)
}

function Write-Log
{
	<#
	.SYNOPSIS
		This function creates or appends a line to a log file.
	.PARAMETER  Message
		The message parameter is the log message you'd like to record to the log file.
	.EXAMPLE
		PS C:\> Write-Log -Message 'Value1'
		This example shows how to call the Write-Log function with named parameters.
	#>
	[CmdletBinding()]
	param (
        [Parameter(Mandatory=$false,position = 1)]
        [string]$LogFileName=$ScriptLog,
		[Parameter(Mandatory=$true,position = 0)]
		[string]$Message,
        [Parameter(Mandatory=$false)][switch]$Silent
	)
	
	try
	{
		$DateTime = Get-Date -Format 'MM-dd-yy HH:mm:ss'
		$Invocation = "$($MyInvocation.MyCommand.Source | Split-Path -Leaf):$($MyInvocation.ScriptLineNumber)"
		Add-Content -Value "$DateTime - $Invocation - $Message" -Path $LogFileName
		if (!($Silent)){Write-Host $Message -ForegroundColor Green}
	}
	catch
	{
		Write-Error $_.Exception.Message
	}
}



Function CleanLogfiles([string]$TargetFolder,[int]$DaysOld,[bool]$ListOnly=$False)
{
    write-host -debug -ForegroundColor DarkRed -BackgroundColor Cyan $TargetFolder
    if (Test-Path $TargetFolder) {
        $Now = Get-Date
        $LastWrite = $Now.AddDays(-$daysOld)
        Write-Log -Message "Will check all files for $TargetFolder older than $LastWrite inclusive"
        Try{
            $Files = Get-ChildItem  $TargetFolder -Recurse | Where-Object {$_.Name -like "*.log" -or $_.Name -like "*.blg" -or $_.Name -like "*.etl"}  | where {$_.lastWriteTime -le "$lastwrite"} | Select-Object FullName,Length
        } Catch {
            Write-Log "Issue trying to access $TargetFolder folder or subfolders - you may not have the proper rights or the folder is not in this location - please retry with elevated PowerShell console" -ForegroundColor Yellow -BackgroundColor Blue
            return
        }
        $FilesCount = $Files.Count
        #$TotalFileSizeInKB = "{0:N0}" -f ((($Files | Measure-Object -Property Length -Sum).Sum)/1KB)
        $TotalFileSizeInMB = "{0:N3}" -f ((($Files | Measure-Object -Property Length -Sum).Sum)/1MB)
        $TotalFileSizeInGB = "{0:N3}" -f ((($Files | Measure-Object -Property Length -Sum).Sum)/1GB)
        Write-Log -Message "Found $FilesCount files in $TargetFolder ..."
        Write-Log -Message "Total file size for that folder: $TotalFileSizeInMB MB / $TotalFileSizeInGB GB"
        
        If (!($ListOnly)){
            $Counter = 0
            foreach ($File in $Files)
            {
                $FullFileName = $File.FullName
                Write-Progress -Activity "Cleaning files from $TargetFolder older than $DaysOld days" -Status "Cleaning $FullFileName" -Id 2 -ParentID 1 -PercentComplete $($Counter/$FilesCount*100)
                Write-Log -Message "Deleting file $FullFileName" -Silent
                Remove-Item $FullFileName -ErrorAction SilentlyContinue | out-null
                $Counter++
             }
         } Else {
            Write-Log "INFO: Read only mode, won't delete"
         }
     }
     Else {
        Write-Log "ERROR: The folder $TargetFolder doesn't exist! Check the folder path!"
     }
 }

  #endregion End of Functions section

#Process {

    # Determining IIS Log Directory
    $IISLogDirectory = Get-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name logfile.directory.value
    $IISLogDirectory = $IISLogDirectory -replace "%SystemDrive%", "$($Env:SystemDrive)"
    $IISLogPath=$IISLogDirectory

    # Determining Exchange Logging paths
    $ExchangeInstallPath = $env:ExchangeInstallPath
    $ExchangeLoggingPath="$ExchangeInstallPath" + "Logging\"
    $ETLLoggingPath="$ExchangeInstallPath" + "Bin\Search\Ceres\Diagnostics\ETLTraces\"
    $ETLLoggingPath2="$ExchangeInstallPath" + "Bin\Search\Ceres\Diagnostics\Logs"
    
    # v1.3.4 added DeleteLodCTRBackup folder
    If ($DeleteLodCTRBackup){
        $LodCRTBackupFolderPath = "$ExchangeInstallPath" + "Logging\lodctr_backups"
    }

If (!($NoConfirmation)){  
    # Asking user if he's sure
    $FoldersStringsForMessageBox = $ExchangeInstallPath + "`n" + $ExchangeLoggingPath + "`n" + $ETLLoggingPath + "`n" + $ETLLoggingPath2
    if ($DoNotDelete){
        $Message = "Assessing (Read Only) Log files from $days days ago from in the following folders and their subfolders without deleting:`n`n"
        $Title = "Assessing (Read Only) Log files number and size"
    } Else {
        $Message = "About to attempt REMOVING Log files from $days days ago from in the following folders and their subfolders:`n`n"
        $Title = "Confirm folder content deletions"
    }
    $MessageBottom = "`n`nOK = Continue, Cancel = Abort"
    $Msg = $message + $FoldersStringsForMessageBox + $MessageBottom
    $UserResponse = Msgbox -msg $Msg -Title $title -Button OKCancel

    If ($UserResponse -eq "Cancel") {Write-host "File deletion script ended by user." -BackgroundColor Green;exit}
 }


#Checking if user specified "-DoNotDelete" to determine if we run deletion in CleanLogFiles function or not...   
If ($DoNotDelete){
    $ListOnlyMode = $True
} Else {
    $ListOnlyMode = $False
}

Write-Progress -Activity "Logging cleanup" -Status "IIS Logs" -Id 1 -PercentComplete 0
    CleanLogfiles -TargetFolder $IISLogPath -DaysOld $Days -ListOnly $ListOnlyMode

Write-Progress -Activity "Logging cleanup" -Status "Deleting log files from Exchange Logging" -Id 1 -PercentComplete 25
    CleanLogfiles -TargetFolder $ExchangeLoggingPath -DaysOld $Days -ListOnly $ListOnlyMode

Write-Progress -Activity "Logging cleanup" -Status "Deleting ETL traces" -Id 1 -PercentComplete 50
    CleanLogfiles -TargetFolder $ETLLoggingPath -DaysOld $Days -ListOnly $ListOnlyMode

Write-Progress -Activity "Logging cleanup" -Status "Deleting other ETL traces" -Id 1 -PercentComplete 75
  CleanLogfiles -TargetFolder $ETLLoggingPath2 -DaysOld $Days -ListOnly $ListOnlyMode

if ($DeleteLodCTRBackup) {
  Write-Progress -Activity "Logging cleanup" -Status "Chose to delete LodCTRfiles" -Id 1 -PercentComplete 85
  CleanLogfiles -TargetFolder $LodCRTBackupFolderPath -DaysOld $Days -ListOnly $ListOnlyMode
}



Write-Progress -Activity "Logging cleanup" -Status "CLEANUP COMPLETE" -Id 1 -PercentComplete 100

#}


    <# ---------------------------- SCRIPT_FOOTER ---------------------------- #>
    #Stopping StopWatch and report total elapsed time (TotalSeconds, TotalMilliseconds, TotalMinutes, etc...
    $stopwatch.Stop()
    $msg = "`n`nThe script took $([math]::round($($StopWatch.Elapsed.TotalSeconds),2)) seconds to execute..."
    Write-Log $msg
    $msg = $null
    $StopWatch = $null
    <# ---------------- /SCRIPT_FOOTER (NOTHING BEYOND THIS POINT) ----------- #>
