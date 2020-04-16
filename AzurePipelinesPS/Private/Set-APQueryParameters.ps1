function Set-APQueryParameters
{
    <#
    .SYNOPSIS

    Returns the formated query parameter string.

    .DESCRIPTION

    Returns the formated query parameter string.

    .PARAMETER InputObject

    The PS bound parameters.

    .PARAMETER SplitProperties

    Switch, splits the properties array into multiple property queries. 
    Example: Get-APIdentityList

    .OUTPUTS

    String, The formated query parameter string.

    .EXAMPLE

    Sets the AP query parameters for the input object.

    Set-APQueryParameters -InputObject $PSBoundParameters

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/?view=vsts-rest-5.0
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [object]
        $InputObject,

        [Parameter()]
        [switch]
        $SplitProperties
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
            'GroupDescriptor'
            'PersonalAccessToken'
        )
        $queryParams = Foreach ($key in $InputObject.Keys)
        {
            If ($nonQueryParams -contains $key)
            {
                Continue
            }
            ElseIf (($key -eq 'Properties') -and $SplitProperties.IsPresent)
            {
                Foreach($prop in $InputObject.$Key)
                {
                    "$key=$prop"
                }
            }
            ElseIf ($key -in 'Top', 'Expand', 'Mine')
            {
                "`$$key=$($InputObject.$key)"
            }
            ElseIf ($key -Match '[A-Za-z0-9]+_[A-Za-z0-9]+') # keys with underscores convert to dot-delimited
            {
                $fixedKey = $key.Replace("_", ".")
                "$fixedKey=$($InputObject.$key)"
            }
            ElseIf ($InputObject.$key.count)
            {
                "$key={0}" -f ($InputObject.$key -join ',')
            }
            Else
            {
                "$key=$($InputObject.$key)"
            }
        }
        Return ($queryParams -join '&')
    }

    end
    {
    }
}
