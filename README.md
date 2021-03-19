# Clean-Exchange-Log-Files
- PowerShell script taken from Edward Van Biljon https://gallery.technet.microsoft.com/office/Clear-Exchange-2013-Log-71abba44 and modified a bit to be more generic

- added progress bars

- added script log file

- No need to modify the IIS and Exchange Path => the script uses environment variables to find the Exhcange Logging and IIS Logging paths.

Usage (example to clean Exchange Logging files and IIS Log files aged 5 days and older:

```powershell

.\CleanExchangeLogFiles.ps1 -Days 5

```

# Download the Latest version of the script

[CleanExchangeLogs.ps1 (latest version)](https://github.com/SammyKrosoft/Clean-Exchange-Log-Files/releases/latest/download/CleanExchangeLogs.ps1)
