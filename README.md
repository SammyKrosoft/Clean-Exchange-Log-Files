# Clean-Exchange-Log-Files

***NOTE: there is an issue when I publish releases of the script - for now I'll just provide the link to the RAW text script, or you can just download the whole repository and just keep the `CleanExchangeLogFiles.ps1` file. Apologizes for the invonvenience***

- PowerShell script taken and adapted from [Edward Van Biljon](https://social.technet.microsoft.com/profile/edward+van+biljon) (was on his Technet Gallery, which has been decommissioned in 2020 (original link: *gallery.technet.microsoft.com/office/Clear-Exchange-2013-Log-71abba44*) with the following modifications:

- No need to modify the IIS and Exchange Path => the script uses environment variables to find the Exchange Logging and IIS Logging paths (script has to be used on Exchange servers to remove the log files)

- added -DoNotDelete switch to just assess the amount of files that we'd potentially remove

- added -NoConfirmation switch to avoir being prompted to continue or cancel

- added progress bars

- added script log file

- Usage 

  - example to view folder sizes only for IIS log files aged 2 days and older:

```powershell

.\CleanExchangeLogFiles.ps1 -Days 2 -DoNotDelete

```

sample output:
![image](https://user-images.githubusercontent.com/33433229/112657665-06928100-8e29-11eb-975f-d08fa14c3775.png)



  - example to clean Exchange Logging files and IIS Log files aged 5 days and older:

```powershell

.\CleanExchangeLogFiles.ps1 -Days 2

```

You'll see the progress bars (one for the folder it's cleaning, and one for the files it's cleaning for each folder):
![image](https://user-images.githubusercontent.com/33433229/112651455-c8925e80-8e22-11eb-9b5b-4dfcc98b0e46.png)

# Usage on a Windows Scheduled task

> NOTE: to use in a Windows Scheduled task, use the `-NoConfirmation` switch to bypass the Confirm Yes/No dialog box. Otherwise the script will just wait for a user input, which will never come because it's a Windows Scheduled task, most likely configured as "non interactive" because we want it to be automatic.
 
In that case, use the -NoConfirmation switch:

```powershell
.\CleanExchangeLogFiles -Days 2 -NoConfirmation
```

This will launch the script in files deletion mode immediately, without the need of a user interaction.


# Log file

The script log file will be located on the user's Documents folder:
![image](https://user-images.githubusercontent.com/33433229/112653994-51aa9500-8e25-11eb-95f3-b643e5f03d3b.png)

And it will contain the same information as on the screen:
![image](https://user-images.githubusercontent.com/33433229/112653900-3f305b80-8e25-11eb-9c7c-946196afb044.png)


# Download the Latest version of the script

[Either download the whole repo, or copy/paste the text of CleanExchangeLogFiles.ps1 from this link](https://raw.githubusercontent.com/SammyKrosoft/Clean-Exchange-Log-Files/master/CleanExchangeLogFiles.ps1)
