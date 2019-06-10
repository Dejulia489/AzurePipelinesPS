# AzurePipelinesPS

A PowerShell module that makes interfacing with Azure Pipelines a bit easier.

## Installing

The module can be installed for the PSGalley by running the command below.

```Powershell
Install-Module AzurePipelinesPS -Repository PSGallery
```

## Building

Run the build script in the root of the project to install dependent modules and start the build

    .\build.ps1

### Default Build

```Powershell
Invoke-Build
```

### Cleaning the Output

```Powershell
Invoke-Build Clean
```

## Session Data

### Creating a Session

```Powershell
$splat = @{
    Collection = 'myCollection'
    Project = 'myProject'
    Instance = 'https://dev.azure.com/'
    PersonalAccessToken = 'myPersonalAccessToken'
    Version = 'vNext'
    SessionName = 'mySession'
}
New-APSession @splat
```

### Saving a Session

Saved session data will persist on disk, it can be retrieved by Get-APSession.

```Powershell
$sessions = Get-APSession
$sessions | Save-APSession
```

### Removing a Session

```Powershell
$sessions = Get-APSession
$sessions | Remove-APSession
```

## Authentication

If a personal access token is provided in the session data it will be used to autheticate by default unless a credential is supplied.
If neither a personal access token or a credential is provided the module will attempt to authenticate with default credentials.
**Default credentials only work for on premise**.

## Development

### Build Status

[![Build status](https://dev.azure.com/michaeldejulia/AzurePipelinesPS/_apis/build/status/AzurePipelinesPS)](https://dev.azure.com/michaeldejulia/AzurePipelinesPS/_build/latest?definitionId=2)

### Pending Work

During development, if a function is not ready to be published as part of the module build, you can append the suffix '.Pending'.
It will be considered a work in progress, the build process will ignore it and so will the repository.

### Versioning

Versioning of the module will happen automatically as part of Invoke-Build. If the build is not invoked from the project's Azure Pipeline the version will persist 1.0 for development.


## Contributors

| <a href="https://github.com/Dejulia489" target="_blank">**Michael DeJulia**</a> | <a href="https://github.com/scrthq" target="_blank">**Nate Ferrell**</a> |
| :---: |:---:|
| [![Dejulia489](https://avatars1.githubusercontent.com/u/24240426?s=200)](https://github.com/Dejulia489) | [![scrthq](https://avatars0.githubusercontent.com/u/12724445?s=200)](https://github.com/scrthq) |
| <a href="https://github.com/Dejulia489" target="_blank">`Dejulia489`</a> | <a href="https://github.com/scrthq" target="_blank">`scrthq`</a> |

## Release Notes

2.0.8

Added Get-APAccessControlListList, Get-APPersonalAccessTokenList and GetAPSecurityNamespaceList. 

2.0.7

Added Write-APLogMessage and Set-APTaskResult. 

2.0.6

Added PSModule support, Register-APPSRepository, Find-APPSModule, Install-APPSModule and New-APFeed.

2.0.5 

Added proxy support, sessions now support a proxy url and credential.

2.0.1 **Breaking Changes**

Updated Wait-APBuild an Wait-APRelease to return once the status of 'inProgress' exits.

1.1.17

Added Get-APWidgetList, Get-APWidget, Add-APWidget, Get-APDashboard and Remove-APDashboard.

1.1.14

Added Get-APInstalledExtension, Get-APInstalledExtensionList and Update-APInstalledExtension.

1.1.11

Added Wait-APBuild and Wait-APRelease timeout errors.

1.1.10

Added Wait-APBuild and Wait-APRelease.
Resolved New-APRelease bug that caused artifact authentication failures.

1.1.7

Resolved Set-APQueryParameters bug that forced all query parameters to lower.

1.1.5

Improved session handling, all functions now support session input in the form of a session name!
Improved session tests!

```Powershell
Get-APBuildList -Session 'mySession'
```

1.1.3

Added Get-APGitItem.

1.1.2

Implemented PSCredentials into session handling and all functions.
You can now save a session with a service account credential to make tooling easier!

1.1.1

Implemented Pester tests for each function, Code Covered 77.48 %!
Deprecated the Version parameter for New-APSession, it has been replaced with ApiVersion.
Creating sessions with tooling made easier!