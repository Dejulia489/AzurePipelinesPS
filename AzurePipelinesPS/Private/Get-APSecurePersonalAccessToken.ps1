Function Get-APSecurePersonalAccessToken
{
    <#
    .SYNOPSIS

    Returns decrypted personal access token that is stored in the module data.

    .DESCRIPTION

    Returns decrypted personal access token that is stored in the module data.

    .PARAMETER Path
    
    The path where module data will be stored, defaults to $Script:ModuleDataPath.
        
    .OUTPUTS

    String, unsecure personal access token.

    .EXAMPLE

    C:\PS> Get-SecurePersonalAccessToken

    .EXAMPLE

    C:\PS> Get-SecurePersonalAccessToken -Path $path

    .LINK

    https://docs.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/authentication-guidance?view=vsts
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [string]
        $Path = $Script:ModuleDataPath   
    )
    Process
    {
        $moduleData = Get-APModuleData
        If($moduleData.PersonalAccessToken)
        {
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($moduleData.PersonalAccessToken)
            $plainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        }
        else
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: Personal access token data was not found: [$Path], run 'Set-APModuleData -PersonalAccessToken' to populate the module data." -ErrorAction Stop
        }
        Return $plainText
    }
}
