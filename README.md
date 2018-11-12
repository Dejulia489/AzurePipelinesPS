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

During development, if a function is not ready to be published as part of the module build, you can append the suffix '.Pending'.
It will be considered a work in progress, the build process will ignore it and so will the repository.