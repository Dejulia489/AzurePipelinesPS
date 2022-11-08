Function Save-APSession
{
    <#
    .SYNOPSIS

    Saves an Azure Pipelines PS session to disk.

    .DESCRIPTION

    Saves an Azure Pipelines PS session to disk.
    The sensetive data is encrypted and stored in the users local application data.
    These saved sessions will be available next time the module is imported. 

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.

    .PARAMETER Path
    
    The path where session data will be stored, defaults to $Script:ModuleDataPath.

    .PARAMETER PassThru
    
    Returns the saved session object.
    
    .INPUTS

    PSbject. Get-APSession, New-APSession

    .OUTPUTS

    None. Save-APSession does not generate any output.

    .EXAMPLE
    
    Creates a session with the name of 'myFirstSession' and saves it to disk.

    $newAPSession = @{
        Collection = 'myCollection'
        Project = 'myFirstProject'
        Instance = 'https://dev.azure.com/'
        PersonalAccessToken = 'myToken'
        Version = 'vNext'
        SessionName = 'myFirstSession'
    }
    New-APSession @newAPSession | Save-APSession 
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
                $possibleValues = Get-APSession | Select-Object -ExpandProperty SessionNAme
                $possibleValues.Where( { $PSitem -match $wordToComplete })
            })]
        [object]
        $Session,
       
        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath
    )
    Begin
    {
        If (-not(Test-Path $Path))
        {
            $data = @{SessionData = @() }
        }
        else 
        {
            $data = Get-Content -Path $Path -Raw | ConvertFrom-Json
        }
    }
    Process
    {
        If ($data.SessionData.Id -notcontains $session.Id)
        {
            $_object = @{
                Version     = $Session.Version
                ApiVersion  = $Session.ApiVersion
                Instance    = $Session.Instance
                Id          = $Session.Id
                SessionName = $Session.SessionName
                Collection  = $Session.Collection
                Project     = $Session.Project
                Saved       = $true
            }
            If ($Session.PersonalAccessToken)
            {
                $_object.PersonalAccessToken = ($Session.PersonalAccessToken | ConvertFrom-SecureString) 
            }
            If ($Session.Credential)
            {
                $_credentialObject = @{
                    Username = $Session.Credential.UserName
                    Password = ($Session.Credential.GetNetworkCredential().SecurePassword | ConvertFrom-SecureString)
                }
                $_object.Credential = $_credentialObject
            }
            If ($Session.Proxy)
            {
                $_object.Proxy = $Session.Proxy
            }
            If ($Session.ProxyCredential)
            {
                $_proxyCredentialObject = @{
                    Username = $Session.ProxyCredential.UserName
                    Password = ($Session.ProxyCredential.GetNetworkCredential().SecurePassword | ConvertFrom-SecureString)
                }
                $_object.ProxyCredential = $_proxyCredentialObject
            }
            $data.SessionData += $_object
            $session | Remove-APSession -Path $Path
        }
    }
    End
    {
        $data | ConvertTo-Json -Depth 5 | Out-File -FilePath $Path
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]: [$SessionName]: Session data has been stored at [$Path]"
    }
}
