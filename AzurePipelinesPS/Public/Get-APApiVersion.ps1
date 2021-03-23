function Get-APApiVersion
{    
    <#
    .SYNOPSIS

    Returns the api version available for the TFS version provided.

    .DESCRIPTION

    Returns the api version available for the TFS version provided.

    .PARAMETER Version
    
    TFS version, this will provide the module with the api version mappings. 

    .OUTPUTS

    String, The api version available for the TFS version provided.

    .EXAMPLE

    Returns the APApiVersion for 'vNext'
    
    Get-APApiVersion -Version 'vNext'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/?view=azure-devops-rest-5.0&viewFallbackFrom=vsts-rest-5.0#api-and-tfs-version-mapping
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [string]
        $Version
    )

    begin
    {
    }

    process
    {
        Switch ($Version)
        {
            'vNext'
            {
                return '5.0-preview'
            }
            '2018 Update 2'
            {
                return '4.0-preview'
            }
            '2018 RTW'
            {
                return '4.0'
            }
            '2017 Update 2'
            {
                return '3.2'
            }
            '2017 Update 1'
            {
                return '3.1'
            }
            '2017 RTW'
            {
                return '3.0'
            } 
            '2015 Update 4'
            {
                return '2.3'
            } 
            '2015 Update 3'
            {
                return '2.3'
            } 
            '2015 Update 2'
            {
                return '2.2'
            } 
            '2015 Update 1'
            {
                return '2.1'
            } 
            '2015 RTW'
            {
                return '2.0'
            }
            default
            {
                Write-Error "[$($MyInvocation.MyCommand.Name)]: [$Version] is not supported, run 'Save-APSession -Version' to populate module data. " -ErrorAction Stop
            }
        }
    }

    end
    {
    }
}
