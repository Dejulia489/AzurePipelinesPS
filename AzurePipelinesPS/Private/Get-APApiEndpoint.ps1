function Get-APApiEndpoint
{    
    <#
    .SYNOPSIS

    Returns the api uri endpoint.

    .DESCRIPTION

    Returns the api uri endpoint base on the api type.

    .PARAMETER ApiType

    Type of the api endpoint to use.

    .OUTPUTS

    String, The uri endpoint that will be used by Set-APUri.

    .EXAMPLE

    Returns the api endpoint for 'release-releases'

    Get-APApiEndpoint -ApiType release-releases

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/?view=vsts-rest-5.0
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]
        $ApiType
    )

    begin
    {
    }

    process
    {
        Switch ($ApiType)
        {
            'build-builds'
            {
                Return '_apis/build/builds'
            }
            'build-buildId'
            {
                Return '_apis/build/builds/{0}'
            }
            'build-definitions'
            {
                Return '_apis/build/definitions'
            }
            'build-definitionId'
            {
                Return '_apis/build/definitions/{0}'
            }
            'packages-agent'
            {
                Return '_apis/distributedTask/packages/agent'
            }
            'policy-configurations'
            {
                Return '_apis/policy/configurations'
            }
            'policy-configurationId'
            {
                Return '_apis/policy/configurations/{0}'
            }
            'policy-types'
            {
                Return '_apis/policy/types'
            }
            'policy-typeId'
            {
                Return '_apis/policy/types/{0}'
            }
            'policy-evaluations'
            {
                Return '_apis/policy/evaluations'
            }
            'policy-evaluationId'
            {
                Return '_apis/policy/evaluations/{0}'
            }
            'policy-revisions'
            {
                Return '_apis/policy/configurations/{0}/revisions'                
            }
            'policy-revisionId'
            {
                Return '_apis/policy/configurations/{0}/revisions/{1}'
            }
            'release-releases'
            {
                Return '_apis/release/releases'
            }
            'release-definitions'
            {
                Return '_apis/release/definitions'
            }
            'release-definitionId'
            {
                Return '_apis/release/definitions/{0}'
            }
            'release-deployments'
            {
                Return '_apis/release/deployments'
            }
            'release-releaseId'
            {
                Return '_apis/release/releases/{0}'
            }
            'release-manualInterventionId'
            {
                Return '_apis/release/releases/{0}/manualinterventions/{1}'
            }
            'release-environmentId'
            {
                Return '_apis/release/releases/{0}/environments/{1}'
            }
            'release-taskId'
            {
                Return '_apis/release/releases/{0}/environments/{1}/deployPhases/{2}/tasks/{3}'
            }
            'release-logs'
            {
                Return '_apis/release/releases/{0}/environments/{1}/deployPhases/{2}/tasks/{3}/logs'
            }
            'release-approvals'
            {
                Return '_apis/release/approvals'
            }
            'release-approvalId'
            {
                Return '_apis/release/approvals/{0}'
            }
            'distributedtask-queues'
            {
                Return '_apis/distributedtask/queues'
            }
            'distributedtask-deploymentgroups'
            {
                Return '_apis/distributedtask/deploymentgroups'
            }
            'distributedtask-deploymentGroupId'
            {
                Return '_apis/distributedtask/deploymentgroups/{0}'
            }
            'distributedtask-targets'
            {
                Return '_apis/distributedtask/deploymentgroups/{0}/targets'
            }
            'distributedtask-targetId'
            {
                Return '_apis/distributedtask/deploymentgroups/{0}/targets/{1}'
            }
            'distributedtask-variablegroups'
            {
                Return '_apis/distributedtask/variablegroups'
            }
            'distributedtask-variablegroupId'
            {
                Return '_apis/distributedtask/variablegroups/{0}'
            }
            'git-repositories'
            {
                Return '_apis/git/repositories'
            }
            'git-repositoryId'
            {
                Return '_apis/git/repositories/{0}'
            }
            'git-refs'
            {
                Return '_apis/git/repositories/{0}/refs'
            }
            'git-pushes'
            {
                Return '_apis/git/repositories/{0}/pushes'
            }
            'git-pullRequests'
            {
                Return '_apis/git/repositories/{0}/pullrequests'
            }
            'project-projects'
            {
                Return '_apis/projects'
            }
            'taskgroup-taskgroups'
            {
                Return '_apis/distributedtask/taskgroups'
            }
            'feed-feeds'
            {
                Return '_apis/packaging/feeds'
            }
            'feed-feedId'
            {
                Return '_apis/packaging/feeds/{0}'
            }
            'feed-packages'
            {
                Return '_apis/packaging/feeds/{0}/packages'
            }
            'feed-packageId'
            {
                Return '_apis/packaging/feeds/{0}/packages/{1}'
            }
            'feed-packageVersion'
            {
                Return '_apis/packaging/feeds/{0}/nuget/packages/{1}/versions/{2}'
            }
            'feed-RBpackageVersion'
            {
                Return '_apis/packaging/feeds/{0}/nuget/RecycleBin/packages/{1}/versions/{2}'
            }
            'feed-packageContent'
            {
                Return '_apis/packaging/feeds/{0}/nuget/packages/{1}/versions/{2}/content'
            }
            'graph-userId'
            {
                Return '_apis/graph/users/{0}'
            }
            'graph-users'
            {
                Return '_apis/graph/users'
            }
            'graph-groupId'
            {
                Return '_apis/graph/groups/{0}'
            }
            'graph-groups'
            {
                Return '_apis/graph/groups'
            }
            'graph-descriptorStorageKey'
            {
                Return '_apis/graph/descriptors/{0}'
            }

            'graph-storagekeys'
            {
                Return '_apis/graph/storagekeys/{0}'
            }
            'graph-memberships'
            {
                Return '_apis/graph/Memberships/{0}'
            }
            'graph-containerDescriptor'
            {
                Return '_apis/graph/Memberships/{0}/{1}'
            }
            'groupentitlements-entitlements'
            {
                Return '_apis/groupentitlements'
            }
            'team-teams'
            {
                Return '_apis/teams'
            }
            'team-projectId'
            {
                Return '_apis/projects/{0}/teams'
            }
            'team-teamId'
            {
                Return '_apis/projects/{0}/teams/{1}'
            }
            'git-deletedrepositories'
            {
                Return '_apis/git/deletedrepositories'
            }
            'git-recycleBin'
            {
                Return '_apis/git/recycleBin/repositories'
            }
            'git-items'
            {
                Return '_apis/git/repositories/{0}/items'
            }
            'extensionmanagement-installedextensions'
            {
                Return '_apis/extensionmanagement/installedextensions'
            }
            'extensionmanagement-installedextensionsbyname'
            {
                Return '_apis/extensionmanagement/installedextensionsbyname/{0}/{1}'
            }
            'extensionmanagement-collection'
            {
                Return '_apis/extensionmanagement/installedextensions/{0}/{1}/Data/Scopes/{2}/{3}/Collections/{4}/Documents'
            }
            'extensionmanagement-documentId'
            {
                Return '_apis/extensionmanagement/installedextensions/{0}/{1}/Data/Scopes/{2}/{3}/Collections/{4}/Documents/{5}'
            }
            'dashboard-dashboards'
            {
                Return '_apis/dashboard/dashboards'
            }
            'dashboard-dashboardId'
            {
                Return '_apis/dashboard/dashboards/{0}'
            }
            'dashboard-widgets'
            {
                Return '_apis/dashboard/dashboards/{0}/widgets'
            }
            'dashboard-widgetId'
            {
                Return '_apis/dashboard/dashboards/{0}/widgets/{1}'
            }
            'packaging-feedName'
            {
                Return '_packaging/{0}/nuget/v2'
            }
            'securitynamespaces-securityNamespaceId'
            {
                Return '_apis/securitynamespaces/{0}'
            }
            'sourceProviders-sourceproviders'
            {
                Return '_apis/sourceproviders'
            }
            'sourceProviders-branches'
            {
                Return '_apis/sourceProviders/{0}/branches'
            }
            'notification-subscriptions'
            {
                Return '_apis/notification/subscriptions'
            }
            'notification-subscriptionId'
            {
                Return '_apis/notification/subscriptions/{0}'
            }
            'notification-subscriptionTemplates'
            {
                Return '_apis/notification/subscriptiontemplates'
            }
            'accesscontrollists-securityNamespaceId'
            {
                Return '_apis/accesscontrollists/{0}'
            }
            'accesscontrolentries-securityNamespaceId'
            {
                Return '_apis/accesscontrolentries/{0}'
            }
            'serviceendpoint-endpoints'
            {
                Return '_apis/serviceendpoint/endpoints'
            }
            'serviceendpoint-endpointId'
            {
                Return '_apis/serviceendpoint/endpoints/{0}'
            }
            'serviceendpoint-types'
            {
                Return '_apis/serviceendpoint/types'
            }
            'serviceendpoint-executionhistory'
            {
                Return '_apis/serviceendpoint/{0}/executionhistory'
            }
            'serviceendpoint-endpointproxy'
            {
                Return '_apis/serviceendpoint/endpointproxy'
            }
            'tokenadmin-subjectDescriptor'
            {
                Return '_apis/tokenadmin/personalaccesstokens/{0}'
            }
            default
            {
                Write-Error "[$($MyInvocation.MyCommand.Name)]: [$ApiType] is not supported" -ErrorAction Stop
            }
        }
    }

    end
    {
    }
}
