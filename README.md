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

1.1.*

Implemented Pester tests for each function, Code Covered 77.48 %!
Implemented PSCredentials into session handling.
Deprecated the Version parameter for New-APSession, it has been replaced with ApiVersion.