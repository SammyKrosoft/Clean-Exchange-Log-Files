<# Changes tracking
v1.1 - replaced $Files = Get-ChildItem "C:\Program Files\Microsoft\Exchange\..." with Get-ChildItem $TargetFolder argument
v1.2 - replaced Write-Host "Deleting file ..." with progress bar
v1.3 - fixed Exchange directories to use environment variable instead of hard coded C:\Program Files\Microsoft\Exchange\...
#>
# Set-Executionpolicy RemoteSigned
$days=0
$IISLogPath="C:\inetpub\logs\LogFiles\"
$CurrentExchangeInstallPath = $env:ExchangeInstallPath
$ExchangeLoggingPath=$CurrentExchangeInstallPath + ("Logging\")
$ETLLoggingPath=$CurrentExchangeInstallPath + ("Bin\Search\Ceres\Diagnostics\ETLTraces\")
$ETLLoggingPath2=$CurrentExchangeInstallPath + ("Bin\Search\Ceres\Diagnostics\Logs\")
Function CleanLogfiles($TargetFolder)
{
  write-host -debug -ForegroundColor Yellow -BackgroundColor Cyan $TargetFolder

    if (Test-Path $TargetFolder) {
        $Now = Get-Date
        $LastWrite = $Now.AddDays(-$days)
        Try {
            $Files = Get-ChildItem $TargetFolder  -Recurse -ErrorAction STOP | Where-Object {$_.Name -like "*.log" -or $_.Name -like "*.blg" -or $_.Name -like "*.etl"}  | where {$_.lastWriteTime -le "$lastwrite"} | Select-Object FullName 
        } Catch {
            Write-Host "Issue trying to access $TargetFolder folder - you may not have the proper rights or the folder is not in this location - please retry with elevated PowerShell console" -ForegroundColor Yellow -BackgroundColor Blue
        }

        $Counter = 0
        
        foreach ($File in $Files)
            {
                $ProgressMessage = "Deleting file $FullFileName"
                Write-Progress -Activity "Deleting files from $TargetFolder" -Status $ProgressMessage -Id 2 -ParentId 1 -PercentComplete $($Counter/$($Files.count)*100)
                $FullFileName = $File.FullName
                Remove-Item $FullFileName -ErrorAction SilentlyContinue | out-null
                $counter++
            }
       }
    Else {
        Write-Host "The folder $TargetFolder doesn't exist! Check the folder path!" -ForegroundColor "red"
    }
}

Write-Progress -Activity "Logging cleanup" -Status "IIS Logs" -Id 1 -PercentComplete 0
CleanLogfiles($IISLogPath)

Write-Progress -Activity "Logging cleanup" -Status "Deleting log files from Exchange Logging" -Id 1 -PercentComplete 25
CleanLogfiles($ExchangeLoggingPath)

Write-Progress -Activity "Logging cleanup" -Status "Deleting ETL traces" -Id 1 -PercentComplete 50
CleanLogfiles($ETLLoggingPath)

Write-Progress -Activity "Logging cleanup" -Status "Deleting other ETL traces" -Id 1 -PercentComplete 75
CleanLogfiles($ETLLoggingPath2)

Write-Progress -Activity "Logging cleanup" -Status "CLEANUP COMPLETE" -Id 1 -PercentComplete 100
