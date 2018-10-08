function Set-APAuthenticationType
{    
    <#
    .SYNOPSIS

    Sets the authentication type used by Invoke-APRestMethod.

    .DESCRIPTION

    Sets the authentication type used by Invoke-APRestMethod.
    Default authentication will use the pesonal access token that is stored in module data, unless a credential is supplied to the function.

    .PARAMETER InputObject
    
    The splat parameters used by Invoke-APRestMethod.

    .PARAMETER Credential

    Specifies a user account that has permission to send the request.
    
    .OUTPUTS

    PSObject, The modifed inputobject.

    .EXAMPLE

    C:\PS> Set-APAuthenticationType -InputObject $inputObject

    .EXAMPLE

    C:\PS> Set-APAuthenticationType -InputObject $inputObject -Credential $pscredential

    .LINK

    https://docs.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/authentication-guidance?view=vsts
    #>
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory)]
        [PSObject]
        $InputObject,

        [Parameter()]
        [pscredential]
        $Credential
    )

    begin
    {
    }

    process
    {
        If ($Credential)
        {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Authenticating with the provided credential."
            $InputObject.Credential = $Credential
        }
        ElseIf ((Get-APModuleData).PersonalAccessToken)
        {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Authenticating with the stored personal access token."
            $PersonalAccessTokenToken = Get-APSecurePersonalAccessToken
            $encodedPersonalAccessToken = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$PersonalAccessTokenToken"))
            $InputObject.Headers = @{Authorization = "Basic $encodedPersonalAccessToken"}
        }
        Else
        {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)]: Authenticating with default credentials"
            $InputObject.UseDefaultCredentials = $true
        }
    }

    end
    {
        Return $InputObject
    }
}
