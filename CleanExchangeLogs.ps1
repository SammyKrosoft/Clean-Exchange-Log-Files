
<#PSScriptInfo

.VERSION 1.0

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
    Script taken from Edward van Biljon https://gallery.technet.microsoft.com/office/Clear-Exchange-2013-Log-71abba44

.LINK
    https://gallery.technet.microsoft.com/office/Clear-Exchange-2013-Log-71abba44
    https://github.com/SammyKrosoft/Clean-Exchange-Log-Files

#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)][switch]$CheckVersion
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
$ScriptVersion = "0.1"
<# Version changes
v0.1 : first script version
v0.1 -> v0.5 : 
#>

$ScriptName = $MyInvocation.MyCommand.Name
If ($CheckVersion) {Write-Host "SCRIPT NAME     : $ScriptName `nSCRIPT VERSION  : $ScriptVersion";exit}
# Log or report file definition
$UserDocumentsFolder = "$($env:APPDATA)\Documents"
$OutputReport = "$UserDocumentsFolder\$($ScriptName)_Output_$(get-date -f yyyy-MM-dd-hh-mm-ss).csv"
# Other Option for Log or report file definition (use one of these)
$ScriptLog = "$UserDocumentsFolder\$($ScriptName)_Logging_$(Get-Date -Format 'dd-MMMM-yyyy-hh-mm-ss-tt').txt"
<# ---------------------------- /SCRIPT_HEADER ---------------------------- #>
Begin {
    #Checks if the user is in the administrator group. Warns and stops if the user is not.
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        Write-Host "You are not running this as local administrator. Run it again in an elevated prompt." -BackgroundColor Red; exit
    }
}
Set-Executionpolicy RemoteSigned
$days=0

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
  
    $FoldersStringsForMessageBox = $ExchangeInstallPath + "`n" + $ExchangeLoggingPath + "`n" + $ETLLoggingPath + "`n" + $ETLLoggingPath2
    $Message = "About to attempt removing Log files in the following folders and their subfolders:`n`n"
    $MessageBottom = "`n`nOK = Continue, Cancel = Abort"
    $Msg = $message + $FoldersStringsForMessageBox + $MessageBottom
    

    $UserResponse = Msgbox -msg $Msg -Title "Confirm folder content deletions" -Button OKCancel

    If ($UserResponse -eq "Cancel") {Write-host "File deletion script ended by user." -BackgroundColor Green;exit}

    #Checking if log paths above exist
    # Try {Test-Path $ExchangeLoggingPath;Write-Host "$ExchangeLoggingPath folder exists" -BackgroundColor Green} catch {Write-Host "Error testing path $ExchangeLoggingPath" -BackgroundColor Red;exit}
    # Try {Test-Path $ETLLoggingPath;Write-Host "$ETLLoggingPath folder exists" -BackgroundColor Green} catch {Write-Host "Error testing path $ETLLoggingPath" -BackgroundColor Red;exit}
    # Try {Test-Path $ETLLoggingPath2;Write-Host "$ETLLoggingPath2 folder exists" -BackgroundColor Green} catch {Write-Host "Error testing path $ETLLoggingPath2" -BackgroundColor Red;exit}


    Function CleanLogfiles($TargetFolder)
    {
    write-host -debug -ForegroundColor Yellow -BackgroundColor Cyan $TargetFolder

        if (Test-Path $TargetFolder) {
            $Now = Get-Date
            $LastWrite = $Now.AddDays(-$days)
        #   $Files = Get-ChildItem $TargetFolder -Include *.log,*.blg, *.etl -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}
            $Files = Get-ChildItem "C:\Program Files\Microsoft\Exchange Server\V15\Logging\"  -Recurse | Where-Object {$_.Name -like "*.log" -or $_.Name -like "*.blg" -or $_.Name -like "*.etl"}  | where {$_.lastWriteTime -le "$lastwrite"} | Select-Object FullName  
            $FilesCount = $Files.Count
            Write-Host "Found $FilesCount files in $TargetFolder ... continue Y/N ?"
            foreach ($File in $Files)
                {
                $FullFileName = $File.FullName  
                Write-Host "Deleting file $FullFileName" -ForegroundColor "yellow"; 
                    Remove-Item $FullFileName -ErrorAction SilentlyContinue | out-null
                }
        }
    Else {
        Write-Host "The folder $TargetFolder doesn't exist! Check the folder path!" -ForegroundColor "red"
        }
    }
    CleanLogfiles($IISLogPath)
    CleanLogfiles($ExchangeLoggingPath)
    CleanLogfiles($ETLLoggingPath)
    CleanLogfiles($ETLLoggingPath2)
#}

End {
    <# ---------------------------- SCRIPT_FOOTER ---------------------------- #>
    #Stopping StopWatch and report total elapsed time (TotalSeconds, TotalMilliseconds, TotalMinutes, etc...
    $stopwatch.Stop()
    $msg = "`n`nThe script took $([math]::round($($StopWatch.Elapsed.TotalSeconds),2)) seconds to execute..."
    Write-Host $msg
    $msg = $null
    $StopWatch = $null
    <# ---------------- /SCRIPT_FOOTER (NOTHING BEYOND THIS POINT) ----------- #>
}