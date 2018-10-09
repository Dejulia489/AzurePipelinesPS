Function Save-APSession
{
    <#
    .SYNOPSIS

    Stores session data.

    .DESCRIPTION

    Stores session data that persists to disk.
    The sensetive data is encrypted and stored in the users local application data.

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.

    .PARAMETER Path
    
    The path where session data will be stored, defaults to $Script:ModuleDataPath.
    
    .INPUTS

    None. You cannot pipe objects to Save-APSession.

    .OUTPUTS

    None. Save-APSession returns nothing.

    .EXAMPLE
    
    C:\PS> Save-APSession -Instance 'https://.dev.azure.com/' -Collection 'myOrganization'

    .EXAMPLE

    C:\PS> Save-APSession -Instance 'https://myproject.visualstudio.com' -Collection 'DefaultCollection'

    .EXAMPLE

    C:\PS> Save-APSession -PersonalAccessToken 'myPatToken'

    .LINK

    Get-APModuleData
    Remove-APModuleData
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [object]
        $Session,
       
        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath        
    )
    Begin
    {
        If (-not($Script:ModuleDataPath))
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)] requires the global variable ModuleData that is populated during module import, please import the module." -ErrorAction Stop
        }
        If (-not(Test-Path $Path))
        {
            $data = @{SessionData = @()}
        }
        else 
        {
            $data = Get-Content -Path $Path -Raw | ConvertFrom-Json           
        }
    }
    Process
    {
        $_object = @{
            Version     = $Session.Version
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
        $data.SessionData += $_object
        $session | Remove-APSession
    }
    End
    {
        $data | Convertto-Json -Depth 5 | Out-File -FilePath $Path
        Write-Verbose "[$($MyInvocation.MyCommand.Name)]: [$SessionName]: Session data has been stored at [$Path]"
    }
}
