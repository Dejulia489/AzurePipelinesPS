Function Unprotect-APSecurePersonalAccessToken
{
    <#
    .SYNOPSIS

    Returns decrypted personal access token.

    .DESCRIPTION

    Returns decrypted personal access token that is stored in the session data.

    .PARAMETER PersonalAccessToken

    Personal access token used to authenticate that has been converted to a secure string. 
    It is recomended to uses an Azure Pipelines PS session to pass the personal access token parameter among funcitons, See New-APSession.
    https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts
        
    .OUTPUTS

    String, unsecure personal access token.

    .EXAMPLE

    Unprotects the personal access token from secure string to plain text.

    Unprotect-SecurePersonalAccessToken -PersonalAccessToken $mySecureToken

    .LINK

    https://docs.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/authentication-guidance?view=vsts
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [Security.SecureString]
        $PersonalAccessToken
    )
    Process
    {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PersonalAccessToken)
        $plainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

        if ([environment]::OSVersion.Platform -eq "Unix") {
            $plainText = [System.Net.NetworkCredential]::new("", $PersonalAccessToken).Password
        }

        return $plainText
    }
}
