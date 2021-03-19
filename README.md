# Clean-Exchange-Log-Files
- PowerShell script taken and adapted from [Edward Van Biljon](https://social.technet.microsoft.com/profile/edward+van+biljon) (was on his Technet Gallery, which has been decommissioned in 2020 (original link: *gallery.technet.microsoft.com/office/Clear-Exchange-2013-Log-71abba44*) with the following modifications:

- No need to modify the IIS and Exchange Path => the script uses environment variables to find the Exchange Logging and IIS Logging paths (script has to be used on Exchange servers to remove the log files)

- added -DoNotDelete switch to just assess the amount of files that we'd potentially remove

- added progress bars

- added script log file

- Usage 

  - example to view folder sizes only for IIS log files aged 2 days and older:

```powershell

.\CleanExchangeLogFiles.ps1 -Days 2 -DoNotDelete

```

sample output:
```output
C:\inetpub\logs\LogFile
Last Write Time for C:\inetpub\logs\LogFile : 03/19/2021 15:09:46
Found 2 files in C:\inetpub\logs\LogFile ...
Total file size for that folder: 11,035 KB / 11 MB / 0 GB
INFO: Read only mode, won't delete
C:\Program Files\Microsoft\Exchange Server\Logging\
Last Write Time for C:\Program Files\Microsoft\Exchange Server\Logging\ : 03/19/2021 15:09:46
Found 759 files in C:\Program Files\Microsoft\Exchange Server\Logging\ ...
Total file size for that folder: 451,151 KB / 441 MB / 0 GB
INFO: Read only mode, won't delete
C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\ETLTraces\
Last Write Time for C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\ETLTraces\ : 03/19/2021 15:09:46
Found  files in C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\ETLTraces\ ...
Total file size for that folder: 768 KB / 1 MB / 0 GB
INFO: Read only mode, won't delete
C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\Logs
Last Write Time for C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\Logs : 03/19/2021 15:09:46
Found  files in C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\Logs ...
Total file size for that folder: 603 KB / 1 MB / 0 GB
INFO: Read only mode, won't delete


The script took 2.01 seconds to execute...
```

  - example to clean Exchange Logging files and IIS Log files aged 5 days and older:

```powershell

.\CleanExchangeLogFiles.ps1 -Days 5

```

# Download the Latest version of the script

[Download latest version of CleanExchangeLogs.ps1](https://github.com/SammyKrosoft/Clean-Exchange-Log-Files/releases/latest/download/CleanExchangeLogs.ps1)
