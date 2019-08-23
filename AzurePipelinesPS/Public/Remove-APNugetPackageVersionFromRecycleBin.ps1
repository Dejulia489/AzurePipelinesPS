function Remove-APNugetPackageVersionFromRecycleBin
{
    <#
    .SYNOPSIS

    Deletes an Azure Pipeline nuget package version from the recyle bin.

    .DESCRIPTION

    Deletes an Azure Pipeline nuget package version from the recycle bin by feed id, package name, and package version.
    The id can be retrieved by using Get-APFeedList.
    The package name and version can be retrieved by using Get-APPackageList.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    For Azure DevOps the value should be https://dev.azure.com/.
    
    .PARAMETER Collection
    
    For Azure DevOps the value for collection should be the name of your orginization. 
    For both Team Services and TFS The value should be DefaultCollection unless another collection has been created.

    .PARAMETER ApiVersion
    
    Version of the api to use.

    .PARAMETER PersonalAccessToken
    
    Personal access token used to authenticate that has been converted to a secure string. 
    It is recomended to uses an Azure Pipelines PS session to pass the personal access token parameter among funcitons, See New-APSession.
    https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=vsts
    
    .PARAMETER Credential

    Specifies a user account that has permission to send the request.

    .PARAMETER Proxy
    
    Use a proxy server for the request, rather than connecting directly to the Internet resource. Enter the URI of a network proxy server.

    .PARAMETER ProxyCredential
    
    Specifie a user account that has permission to use the proxy server that is specified by the -Proxy parameter. The default is the current user.

    .PARAMETER Session

    Azure DevOps PS session, created by New-APSession.

    .PARAMETER FeedId
    
    The id of the feed to be deleted.

    .PARAMETER PackageName

    The name of the package to be deleted.

    .PARAMETER PackageVersion

    The version of the package to be deleted.

    .INPUTS
    
    None, does not support pipeline.

    .OUTPUTS

    None, Remove-APNugetPackageVersionFromRecycleBin does not support output.

    .EXAMPLE

    Deletes AP feed with the id of '5' from the recycle bin.

    Remove-APNugetPackageVersionFromRecycleBin -Instance 'https://dev.azure.com' -Collection 'myCollection' -Project 'myFirstProject' -FeedId 5 -PackageName 'myPackage' -PackageVersion 'myPackageVersion'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/azure/devops/artifactspackagetypes/nuget/delete%20package%20version%20from%20recycle%20bin?view=azure-devops-rest-5.0
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByPersonalAccessToken')]
    Param
    (
        [Parameter(Mandatory,
            ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(Mandatory,
            ParameterSetName = 'ByCredential')]
        [uri]
        $Instance,

        [Parameter(Mandatory,
            ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(Mandatory,
            ParameterSetName = 'ByCredential')]
        [string]
        $Collection,

        [Parameter(Mandatory,
            ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(Mandatory,
            ParameterSetName = 'ByCredential')]
        [string]
        $ApiVersion,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Security.SecureString]
        $PersonalAccessToken,

        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [string]
        $Proxy,

        [Parameter(ParameterSetName = 'ByPersonalAccessToken')]
        [Parameter(ParameterSetName = 'ByCredential')]
        [pscredential]
        $ProxyCredential,

        [Parameter(Mandatory,
            ParameterSetName = 'BySession')]
        [object]
        $Session,
                
        [Parameter(Mandatory)]
        [string]
        $FeedId,
        
        [Parameter(Mandatory)]
        [string]
        $PackageName,

        [Parameter(Mandatory)]
        [string]
        $PackageVersion
    )

    begin
    {
        If ($PSCmdlet.ParameterSetName -eq 'BySession')
        {
            $currentSession = $Session | Get-APSession
            If ($currentSession)
            {
                $Instance = $currentSession.Instance
                $Collection = $currentSession.Collection
                $PersonalAccessToken = $currentSession.PersonalAccessToken
                $Credential = $currentSession.Credential
                $Proxy = $currentSession.Proxy
                $ProxyCredential = $currentSession.ProxyCredential
                If ($currentSession.Version)
                {
                    $ApiVersion = (Get-APApiVersion -Version $currentSession.Version)
                }
                else
                {
                    $ApiVersion = $currentSession.ApiVersion
                }
            }
        }
    }
    
    process
    {
        $apiEndpoint = (Get-APApiEndpoint -ApiType 'feed-RBpackageVersion') -f $FeedId, $PackageName, $PackageVersion
        $setAPUriSplat = @{
            Collection  = $Collection
            Instance    = $Instance
            ApiVersion  = $ApiVersion
            ApiEndpoint = $apiEndpoint
        }
        [uri] $uri = Set-APUri @setAPUriSplat
        $invokeAPRestMethodSplat = @{
            Method              = 'DELETE'
            Uri                 = $uri
            Credential          = $Credential
            PersonalAccessToken = $PersonalAccessToken
            Proxy               = $Proxy
            ProxyCredential     = $ProxyCredential
        }
        Invoke-APRestMethod @invokeAPRestMethodSplat 
    }
    
    end
    {
    }
}