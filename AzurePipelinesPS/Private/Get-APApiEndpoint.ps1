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
            'accesscontrollists-securityNamespaceId'
            {
                return '_apis/accesscontrollists/{0}'
            }
            'accesscontrolentries-securityNamespaceId'
            {
                return '_apis/accesscontrolentries/{0}'
            }
            'agent-agents'
            {
                return '_apis/distributedtask/pools/{0}/agents'
            }
            'agent-agentId'
            {
                return '_apis/distributedtask/pools/{0}/agents/{1}'
            }
            'build-builds'
            {
                return '_apis/build/builds'
            }
            'build-buildId'
            {
                return '_apis/build/builds/{0}'
            }
            'build-timeline'
            {
                return '_apis/build/builds/{0}/timeline'
            }
            'build-timelineId'
            {
                return '_apis/build/builds/{0}/timeline/{1}'
            }
            'build-definitions'
            {
                return '_apis/build/definitions'
            }
            'build-definitionId'
            {
                return '_apis/build/definitions/{0}'
            }
            'build-artifacts'
            {
                return '_apis/build/builds/{0}/artifacts'
            }
            'build-leases'
            {
                return '_apis/build/retention/leases'
            }
            'build-leaseId'
            {
                return '_apis/build/retention/leases/{0}'
            }
            'distributedtask-queues'
            {
                return '_apis/distributedtask/queues'
            }
            'distributedtask-deploymentgroups'
            {
                return '_apis/distributedtask/deploymentgroups'
            }
            'distributedtask-deploymentGroupId'
            {
                return '_apis/distributedtask/deploymentgroups/{0}'
            }
            'distributedtask-environments'
            {
                return '_apis/distributedtask/environments'
            }           
            'distributedtask-environmentId'
            {
                return '_apis/distributedtask/environments/{0}'
            }
            'distributedtask-targets'
            {
                return '_apis/distributedtask/deploymentgroups/{0}/targets'
            }
            'distributedtask-targetId'
            {
                return '_apis/distributedtask/deploymentgroups/{0}/targets/{1}'
            }
            'distributedtask-variablegroups'
            {
                return '_apis/distributedtask/variablegroups'
            }
            'distributedtask-variablegroupId'
            {
                return '_apis/distributedtask/variablegroups/{0}'
            }
            'dashboard-dashboards'
            {
                return '_apis/dashboard/dashboards'
            }
            'dashboard-dashboardId'
            {
                return '_apis/dashboard/dashboards/{0}'
            }
            'dashboard-widgets'
            {
                return '_apis/dashboard/dashboards/{0}/widgets'
            }
            'dashboard-widgetId'
            {
                return '_apis/dashboard/dashboards/{0}/widgets/{1}'
            }
            'extensionmanagement-installedextensions'
            {
                return '_apis/extensionmanagement/installedextensions'
            }
            'extensionmanagement-installedextensionsbyname'
            {
                return '_apis/extensionmanagement/installedextensionsbyname/{0}/{1}'
            }
            'extensionmanagement-collection'
            {
                return '_apis/extensionmanagement/installedextensions/{0}/{1}/Data/Scopes/{2}/{3}/Collections/{4}/Documents'
            }
            'extensionmanagement-documentId'
            {
                return '_apis/extensionmanagement/installedextensions/{0}/{1}/Data/Scopes/{2}/{3}/Collections/{4}/Documents/{5}'
            }
            'feed-feeds'
            {
                return '_apis/packaging/feeds'
            }
            'feed-feedId'
            {
                return '_apis/packaging/feeds/{0}'
            }
            'feed-packages'
            {
                return '_apis/packaging/feeds/{0}/packages'
            }
            'feed-packageId'
            {
                return '_apis/packaging/feeds/{0}/packages/{1}'
            }
            'feed-packageVersion'
            {
                return '_apis/packaging/feeds/{0}/nuget/packages/{1}/versions/{2}'
            }
            'feed-RBpackageVersion'
            {
                return '_apis/packaging/feeds/{0}/nuget/RecycleBin/packages/{1}/versions/{2}'
            }
            'feed-packageContent'
            {
                return '_apis/packaging/feeds/{0}/nuget/packages/{1}/versions/{2}/content'
            }
            'git-repositories'
            {
                return '_apis/git/repositories'
            }
            'git-repositoryId'
            {
                return '_apis/git/repositories/{0}'
            }
            'git-commits'
            {
                return '_apis/git/repositories/{0}/commits'
            }
            'git-refs'
            {
                return '_apis/git/repositories/{0}/refs'
            }
            'git-pushes'
            {
                return '_apis/git/repositories/{0}/pushes'
            }
            'git-pullRequests'
            {
                return '_apis/git/repositories/{0}/pullrequests'
            }
            'git-deletedrepositories'
            {
                return '_apis/git/deletedrepositories'
            }
            'git-recycleBin'
            {
                return '_apis/git/recycleBin/repositories'
            }
            'git-items'
            {
                return '_apis/git/repositories/{0}/items'
            }
            'graph-identities'
            {
                return '_apis/IdentityPicker/Identities/me/mru/common'
            }
            'graph-userId'
            {
                return '_apis/graph/users/{0}'
            }
            'graph-users'
            {
                return '_apis/graph/users'
            }
            'graph-groupId'
            {
                return '_apis/graph/groups/{0}'
            }
            'graph-groups'
            {
                return '_apis/graph/groups'
            }
            'graph-descriptorStorageKey'
            {
                return '_apis/graph/descriptors/{0}'
            }
            'graph-storagekeys'
            {
                return '_apis/graph/storagekeys/{0}'
            }
            'graph-memberships'
            {
                return '_apis/graph/memberships/{0}'
            }
            'graph-containerDescriptor'
            {
                return '_apis/graph/memberships/{0}/{1}'
            }
            'groupentitlements-entitlements'
            {
                return '_apis/groupentitlements'
            }
            'notification-subscriptions'
            {
                return '_apis/notification/subscriptions'
            }
            'notification-subscriptionId'
            {
                return '_apis/notification/subscriptions/{0}'
            }
            'notification-subscriptionTemplates'
            {
                return '_apis/notification/subscriptiontemplates'
            }
            'operations-operationId'
            {
                return '_apis/operations/{0}'
            }
            'packaging-feedName'
            {
                return '_packaging/{0}/nuget/v2'
            }
            'packages-agent'
            {
                return '_apis/distributedTask/packages/agent'
            }
            'permissions'
            {
                return '_apis/permissionsreport'
            }
            'permissions-reportId'
            {
                return '_apis/permissionsreport/{0}'
            }
            'permissions-download'
            {
                return '_apis/permissionsreport/{0}/download'
            }
            'pipelines'
            {
                return '_apis/pipelines'
            }
            'pipelines-approvals'
            {
                return '_apis/pipelines/approvals'
            }
            'pipelines-approvalId'
            {
                return '_apis/pipelines/approvals/{0}'
            }
            'pipelines-pipelineId'
            {
                return '_apis/pipelines/{0}'
            }
            'pipelines-runs'
            {
                return '_apis/pipelines/{0}/runs'
            }
            'pipelines-preview'
            {
                return '_apis/pipelines/{0}/preview'
            }
            'pipelines-runId'
            {
                return '_apis/pipelines/{0}/runs/{1}'
            }
            'pipelines-logs'
            {
                return '_apis/pipelines/{0}/runs/{1}/logs'
            }
            'pipelines-logId'
            {
                return '_apis/pipelines/{0}/runs/{1}/logs/{2}'
            }
            'pipelines-configurations'
            {
                return '_apis/pipelines/checks/configurations'
            }
            'pipelines-endpointId'
            {
                return '_apis/pipelines/pipelinePermissions/endpoint/{0}'
            }
            'policy-configurations'
            {
                return '_apis/policy/configurations'
            }
            'policy-configurationId'
            {
                return '_apis/policy/configurations/{0}'
            }
            'policy-types'
            {
                return '_apis/policy/types'
            }
            'policy-typeId'
            {
                return '_apis/policy/types/{0}'
            }
            'policy-evaluations'
            {
                return '_apis/policy/evaluations'
            }
            'policy-evaluationId'
            {
                return '_apis/policy/evaluations/{0}'
            }
            'policy-revisions'
            {
                return '_apis/policy/configurations/{0}/revisions'
            }
            'policy-revisionId'
            {
                return '_apis/policy/configurations/{0}/revisions/{1}'
            }
            'pool-pools'
            {
                return '_apis/distributedtask/pools'
            }
            'pool-poolId'
            {
                return '_apis/distributedtask/pools/{0}'
            }
            'project-projects'
            {
                return '_apis/projects'
            }
            'project-projectId'
            {
                return '_apis/projects/{0}'
            }
            'release-releases'
            {
                return '_apis/release/releases'
            }
            'release-definitions'
            {
                return '_apis/release/definitions'
            }
            'release-definitionId'
            {
                return '_apis/release/definitions/{0}'
            }
            'release-deployments'
            {
                return '_apis/release/deployments'
            }
            'release-releaseId'
            {
                return '_apis/release/releases/{0}'
            }
            'release-manualInterventionId'
            {
                return '_apis/release/releases/{0}/manualinterventions/{1}'
            }
            'release-environmentId'
            {
                return '_apis/release/releases/{0}/environments/{1}'
            }
            'release-taskId'
            {
                return '_apis/release/releases/{0}/environments/{1}/deployPhases/{2}/tasks/{3}'
            }
            'release-logs'
            {
                return '_apis/release/releases/{0}/environments/{1}/deployPhases/{2}/tasks/{3}/logs'
            }
            'release-approvals'
            {
                return '_apis/release/approvals'
            }
            'release-approvalId'
            {
                return '_apis/release/approvals/{0}'
            }
            'serviceendpoint-endpoints'
            {
                return '_apis/serviceendpoint/endpoints'
            }
            'serviceendpoint-endpointId'
            {
                return '_apis/serviceendpoint/endpoints/{0}'
            }
            'serviceendpoint-types'
            {
                return '_apis/serviceendpoint/types'
            }
            'serviceendpoint-executionhistory'
            {
                return '_apis/serviceendpoint/{0}/executionhistory'
            }
            'serviceendpoint-endpointproxy'
            {
                return '_apis/serviceendpoint/endpointproxy'
            }
            'serviceendpoint-endpointproxy'
            {
                return '_apis/serviceendpoint/endpointproxy'
            }
            'securitynamespaces-securityNamespaceId'
            {
                return '_apis/securitynamespaces/{0}'
            }
            'securefiles-secureFiles'
            {
                return '_apis/distributedtask/securefiles'
            }
            'securefiles-secureFileId'
            {
                return '_apis/distributedtask/securefiles/{0}'
            }
            'sourceProviders-sourceproviders'
            {
                return '_apis/sourceproviders'
            }
            'sourceProviders-branches'
            {
                return '_apis/sourceProviders/{0}/branches'
            }
            'taskgroup-taskgroups'
            {
                return '_apis/distributedtask/taskgroups'
            }
            'team-teams'
            {
                return '_apis/teams'
            }
            'team-projectId'
            {
                return '_apis/projects/{0}/teams'
            }
            'team-teamId'
            {
                return '_apis/projects/{0}/teams/{1}'
            }
            'team-members'
            {
                return '_apis/projects/{0}/teams/{1}/members'
            }
            'test-runs'
            {
                return '_apis/test/runs'
            }
            'test-runId'
            {
                return '_apis/test/runs/{0}'
            }
            'test-statistics'
            {
                return '_apis/test/runs/{0}/statistics'
            }
            'test-results'
            {
                return '_apis/test/Runs/{0}/results'
            }
            'test-testCaseId'
            {
                return '_apis/test/runs/{0}/results/{1}'
            }
            'test-testPlans'
            {
                return '_apis/testplan/plans'
            }
            'test-testPlanId'
            {
                return '_apis/testplan/plans/{0}'
            }
            'test-suites'
            {
                return '_apis/test/plans/{0}/suites'
            }
            'test-suiteId'
            {
                return '_apis/test/plans/{0}/suites/{1}'
            }
            'test-testcases'
            {
                return '_apis/test/plans/{0}/suites/{1}/testcases'
            }
            
            'tokenadmin-subjectDescriptor'
            {
                return '_apis/tokenadmin/personalaccesstokens/{0}'
            }
            'userentitlements-entitlements'
            {
                return '_apis/userentitlements'
            }
            'wit-classificationnodes'
            {
                return '_apis/wit/classificationnodes'
            }
            'wit-path'
            {
                return '_apis/wit/classificationnodes/{0}/{1}'
            }
            'wit-workitemtypecategories'
            {
                return '_apis/wit/workitemtypecategories'
            }
            'wit-queries'
            {
                return '_apis/wit/queries'
            }
            'wit-queryId'
            {
                return '_apis/wit/queries/{0}'
            }
            'wit-workitems'
            {
                return '_apis/wit/workitems'
            }
            'wit-workitemId'
            {
                return '_apis/wit/workitems/{0}'
            }
            'wit-wiql'
            {
                return '_apis/wit/wiql'
            }
            'work-boards'
            {
                return '{0}/_apis/work/boards'
            }
            'work-boardId'
            {
                return '{0}/_apis/work/boards/{1}'
            }
            'work-plans'
            {
                return '_apis/work/plans'
            }
            'work-planId'
            {
                return '_apis/work/plans/{0}'
            }
            'work-processes'
            {
                return '_apis/work/processes'
            }
            'work-lists'
            {
                return '_apis/work/processes/lists'
            }
            'work-listId'
            {
                return '_apis/work/processes/lists/{0}'
            }
            'work-workitemtypes'
            {
                return '_apis/work/processes/{0}/workitemtypes'
            }
            'work-fields'
            {
                return '_apis/work/processes/{0}/workitemtypes/{1}/fields'
            }
            'work-fields'
            {
                return '_apis/work/processes/{0}/workitemtypes/{1}/fields'
            }
            'work-teamsettings'
            {
                return '{0}/_apis/work/teamsettings'
            }
            'work-teamfieldvalues'
            {
                return '{0}/_apis/work/teamsettings/teamfieldvalues'
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
