# Clean-Exchange-Log-Files
- PowerShell script taken from Edward Van Biljon (was on his Technet Gallery, which has been decommissioned in 2020 (original link: *gallery.technet.microsoft.com/office/Clear-Exchange-2013-Log-71abba44*) and modified a bit to be more generic:

- added progress bars

- added script log file

- No need to modify the IIS and Exchange Path => the script uses environment variables to find the Exhcange Logging and IIS Logging paths.

- Usage 

  - example to view folder sizes only for IIS log files aged 2 days and older:

```powershell

.\CleanExchangeLogFiles.ps1 -Days 2 -DoNotDelete

```

sample output:
```output
C:\inetpub\logs\LogFile
Last Write Time for C:\inetpub\logs\LogFile : 03/19/2021 15:07:48
Found 2 files in C:\inetpub\logs\LogFile ...
Total file size for that folder: 10,951 KB / 11 MB / 0 GB
C:\Program Files\Microsoft\Exchange Server\Logging\
Last Write Time for C:\Program Files\Microsoft\Exchange Server\Logging\ : 03/19/2021 15:07:48
Found 5624 files in C:\Program Files\Microsoft\Exchange Server\Logging\ ...
Total file size for that folder: 3,400,914 KB / 3,321 MB / 3 GB
C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\ETLTraces\
Last Write Time for C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\ETLTraces\ : 03/19/2021 15:09:34
Found  files in C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\ETLTraces\ ...
Total file size for that folder: 768 KB / 1 MB / 0 GB
C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\Logs
Last Write Time for C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\Logs : 03/19/2021 15:09:34
Found 110 files in C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\Logs ...
Total file size for that folder: 162,168 KB / 158 MB / 0 GB
```

  - example to clean Exchange Logging files and IIS Log files aged 5 days and older:

```powershell

.\CleanExchangeLogFiles.ps1 -Days 5

```

# Download the Latest version of the script

[Download later version of CleanExchangeLogs.ps1 script](https://github.com/SammyKrosoft/Clean-Exchange-Log-Files/releases/latest/download/CleanExchangeLogs.ps1)
