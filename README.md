# Clean-Exchange-Log-Files

** NOTE: there is an issue when I publish releases of the script - for now I'll just provide the link to the RAW text script, or you can just download the whole repository and just keep the `CleanExchangeLogFiles.ps1` file. Apologizes for the invonvenience **

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
Last Write Time for C:\inetpub\logs\LogFile : 03/19/2021 17:21:14
Found 2 files in C:\inetpub\logs\LogFile ...
Total file size for that folder: 10.78 MB / 0.01 GB
INFO: Read only mode, won't delete
C:\Program Files\Microsoft\Exchange Server\Logging\
Last Write Time for C:\Program Files\Microsoft\Exchange Server\Logging\ : 03/19/2021 17:21:14
Found 1001 files in C:\Program Files\Microsoft\Exchange Server\Logging\ ...
Total file size for that folder: 453.59 MB / 0.44 GB
INFO: Read only mode, won't delete
C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\ETLTraces\
Last Write Time for C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\ETLTraces\ : 03/19/2021 17:21:15
Found  files in C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\ETLTraces\ ...
Total file size for that folder: 0.75 MB / 0.00 GB
INFO: Read only mode, won't delete
C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\Logs
Last Write Time for C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\Logs : 03/19/2021 17:21:15
Found 5 files in C:\Program Files\Microsoft\Exchange Server\Bin\Search\Ceres\Diagnostics\Logs ...
Total file size for that folder: 7.01 MB / 0.01 GB
INFO: Read only mode, won't delete


The script took 2.57 seconds to execute...
```

  - example to clean Exchange Logging files and IIS Log files aged 5 days and older:

```powershell

.\CleanExchangeLogFiles.ps1 -Days 5

```

# Download the Latest version of the script

[Either download the whole repo, or copy/paste the text of CleanExchangeLogs.ps1 from this link](https://raw.githubusercontent.com/SammyKrosoft/Clean-Exchange-Log-Files/master/CleanExchangeLogs.ps1)
