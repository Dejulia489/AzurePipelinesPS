Function Unprotect-APSecurePersonalAccessToken
{
    <#
    .SYNOPSIS

    Returns decrypted personal access token.

    .DESCRIPTION

    Returns decrypted personal access token that is stored in the session data.

    .PARAMETER PersonalAccessToken

    The secure sting of the personal access token, provided by the session data.
        
    .OUTPUTS

    String, unsecure personal access token.

    .EXAMPLE

    C:\PS> Unprotect-SecurePersonalAccessToken

    .EXAMPLE

    C:\PS> Unprotect-SecurePersonalAccessToken -Path $path

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
        Return $plainText
    }
}
