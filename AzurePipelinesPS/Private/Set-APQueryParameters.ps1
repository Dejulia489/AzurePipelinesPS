function Set-APQueryParameters
{    
    <#
    .SYNOPSIS

    Returns the formated query parameter string.

    .DESCRIPTION

    Returns the formated query parameter string.

    .PARAMETER InputObject
    
    The PS bound parameters.

    .OUTPUTS

    String, The formated query parameter string.

    .EXAMPLE

    C:\PS> Set-APQueryParameters -InputObject $PSBoundParameters

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/?view=vsts-rest-5.0
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [object]
        $InputObject
    )

    begin
    {
    }

    process
    {
        $nonQueryParams = @(
            'Instance'
            'Collection'
            'Project'
            'ApiVersion'
            'PersonalAccessToken'
            'Session'
            'Credential'
            'Verbose'
            'Debug'
            'ErrorAction'
            'WarningAction' 
            'InformationAction' 
            'ErrorVariable' 
            'WarningVariable' 
            'InformationVariable' 
            'OutVariable' 
            'OutBuffer'
            'UserDescriptor'
        )
        $queryParams = Foreach ($key in $InputObject.Keys)
        {
            If ($nonQueryParams -contains $key)
            {
                Continue
            }
            ElseIf ($key -eq 'Top')
            {
                "`$$key=$($InputObject.$key)"
            }
            ElseIf ($InputObject.$key.count)
            {
                "$key={0}" -f ($InputObject.$key -join ',')
            }
            else
            {
                "$key=$($InputObject.$key)"                    
            }
        }
        Return ($queryParams -join '&').ToLower()
    }

    end
    {
    }
}
