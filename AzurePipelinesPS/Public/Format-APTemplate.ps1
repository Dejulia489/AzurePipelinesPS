Function Format-APTemplate
{
    <#
    .SYNOPSIS

    Returns an Azure Pipeline build or release template for publishing Azure Pipeline(s).

    .DESCRIPTION

    Returns an Azure Pipeline build or release template for publishing Azure Pipeline(s).
    The templates are defined within this function.

    .PARAMETER Instance
    
    The Team Services account or TFS server.
    
    .PARAMETER Collection
    
    The value for collection should be DefaultCollection for both Team Services and TFS.

    .PARAMETER Project
    
    Project name.

    .PARAMETER Component
    
    Component name, this will be the name of the website or windows service you are trying to deploy.    

    .PARAMETER TemplateName
    
    Template name.

    .PARAMETER Type
    
    The type of template to format, build or release.

    .PARAMETER QueueName
    
    The name of the queue for the build/release.

    .INPUTS
    

    .OUTPUTS

    Json, Azure Pipelines build/release json template ready for publishing.

    .EXAMPLE

    C:\PS> Format-APTemplate -Project 'myFirstProject' -TemplateName 'DotNetWebsite' -Type 'build' -QueueName 'Default' -Component 'myFirstWebsite' -SoultionPath 'myRepo/myBranch/myFirstWebsite.sln'

    .LINK

    https://docs.microsoft.com/en-us/rest/api/vsts/release/releases/list?view=vsts-rest-5.0
    #>
    Param
    (
        [Parameter()]
        [uri]
        $Instance = (Get-APModuleData).Instance,

        [Parameter()]
        [string]
        $Collection = (Get-APModuleData).Collection,

        [Parameter(Mandatory)]
        [string]
        $Project,

        [Parameter(Mandatory)]
        [string]
        $Component,

        [Parameter(Mandatory)]
        [ValidateSet('DotNetWebsite')]
        [String]
        $TemplateName,

        [Parameter(Mandatory)]
        [ValidateSet('build', 'release')]
        [string]
        $Type,

        [Parameter()]
        [String]
        $QueueName,

        [Parameter(ParameterSetName = 'DotNetWebsite')]
        [String]
        $SolutionPath
    )

    Begin
    {
        $templates = @{
            "DotNetWebsite" = @{
                "Build"   = @{
                    options                   = @()
                    variables                 = @{
                        'system.debug' = @{
                            value         = 'false'
                            allowOverride = $true
                        }
                        SolutionPath   = @{
                            value = '%SolutionPath%'
                        }
                        ComponentName  = @{
                            value = '%Component%'
                        }
                    }
                    retentionRules            = @()
                    buildNumberFormat         = '1.0.0.$(rev:r)'
                    jobAuthorizationScope     = 'projectCollection'
                    jobTimeoutInMinutes       = 60
                    jobCancelTimeoutInMinutes = 5
                    process                   = @{
                        phases = @(
                            @{
                                steps                 = @(
                                    @{
                                        environment      = @{
                                        }
                                        enabled          = $true
                                        continueOnError  = $false
                                        alwaysRun        = $false
                                        displayName      = 'NuGet restore'
                                        timeoutInMinutes = 0
                                        condition        = 'succeeded()'
                                        refName          = 'NuGetCommand2'
                                        task             = @{
                                            id             = '333b11bd-d341-40d9-afcf-b32d5ce6f23b'
                                            versionSpec    = '2.*'
                                            definitionType = 'task'
                                        }
                                        inputs           = @{
                                            command                   = 'restore'
                                            solution                  = '$(SolutionPath)'
                                            selectOrConfig            = 'select'
                                            feedRestore               = '2a1e4d15-13bb-4368-bdc8-9d9021ab2467'
                                            includeNuGetOrg           = 'true'
                                            nugetConfigPath           = ''
                                            externalEndpoints         = ''
                                            noCache                   = 'false'
                                            packagesDirectory         = ''
                                            verbosityRestore          = 'Detailed'
                                            searchPatternPush         = '$(Build.ArtifactStagingDirectory)/*.nupkg'
                                            nuGetFeedType             = 'internal'
                                            feedPublish               = ''
                                            allowPackageConflicts     = 'false'
                                            externalEndpoint          = ''
                                            verbosityPush             = 'Detailed'
                                            searchPatternPack         = '**/*.csproj'
                                            configurationToPack       = '$(BuildConfiguration)'
                                            outputDir                 = '$(Build.ArtifactStagingDirectory)'
                                            versioningScheme          = 'off'
                                            includeReferencedProjects = 'false'
                                            versionEnvVar             = ''
                                            requestedMajorVersion     = '1'
                                            requestedMinorVersion     = '0'
                                            requestedPatchVersion     = '0'
                                            packTimezone              = 'utc'
                                            includeSymbols            = 'false'
                                            buildProperties           = ''
                                            verbosityPack             = 'Detailed'
                                            arguments                 = ''
                                        }
                                    }
                                    @{
                                        environment      = @{
                                        }
                                        enabled          = $true
                                        continueOnError  = $false
                                        alwaysRun        = $false
                                        displayName      = 'Build solution'
                                        timeoutInMinutes = 0
                                        condition        = 'succeeded()'
                                        refName          = 'VSBuild1'
                                        task             = @{
                                            id             = '71a9a2d3-a98a-4caa-96ab-affca411ecda'
                                            versionSpec    = '1.*'
                                            definitionType = 'task'
                                        }
                                        inputs           = @{
                                            solution             = '$(SolutionPath)'
                                            vsVersion            = 'latest'
                                            msbuildArgs          = '/p:OutDir=$(build.stagingDirectory) /p:CreatePackageOnPublish=true /p:UseWPP_CopyWebApplication=true /p:PipelineDependsOnBuild=false /p:PrecompileBeforePublish=true'
                                            platform             = ''
                                            configuration        = ''
                                            clean                = 'true'
                                            maximumCpuCount      = 'false'
                                            restoreNugetPackages = 'false'
                                            msbuildArchitecture  = 'x86'
                                            logProjectEvents     = 'true'
                                            createLogFile        = 'false'
                                        }
                                    }
                                    @{
                                        environment      = @{
                                        }
                                        enabled          = $true
                                        continueOnError  = $false
                                        alwaysRun        = $false
                                        displayName      = 'Publish Artifact'
                                        timeoutInMinutes = 0
                                        condition        = 'succeeded()'
                                        refName          = 'PublishBuildArtifacts3'
                                        task             = @{
                                            id             = '2ff763a7-ce83-4e1f-bc89-0ae63477cebe'
                                            versionSpec    = '1.*'
                                            definitionType = 'task'
                                        }
                                        inputs           = @{
                                            PathtoPublish = '$(build.stagingDirectory)\_PublishedWebsites\$(ComponentName)\'
                                            ArtifactName  = '$(ComponentName)'
                                            ArtifactType  = 'Container'
                                            TargetPath    = '\\my\share\$(Build.DefinitionName)\$(Build.BuildNumber)'
                                            Parallel      = 'false'
                                            ParallelCount = '8'
                                        }
                                    }
                                )
                                name                  = $null
                                jobAuthorizationScope = 0
                            }
                        )
                        type   = 1
                    }
                    repository                = @{
                        properties         = @{
                            cleanOptions             = '3'
                            labelSources             = '0'
                            labelSourcesFormat       = '$(build.buildNumber)'
                            reportBuildStatus        = 'true'
                            gitLfsSupport            = 'false'
                            skipSyncSource           = 'false'
                            checkoutNestedSubmodules = 'false'
                            fetchDepth               = '0'
                        }
                        id                 = 'aa6e8b39-2c05-433d-81e1-b252610e3e22'
                        type               = 'TfsGit'
                        name               = '%Project%'
                        url                = 'http://lptfs.life.pacificlife.net:8080/tfs/%Collection%/_git/%Project%'
                        defaultBranch      = 'refs/heads/feature/WAVES'
                        clean              = $false
                        checkoutSubmodules = $false
                    }
                    processParameters         = @{
                    }
                    quality                   = 'definition'
                    queue                     = @{
                        id   = 88
                        name = 'WFPool'
                        pool = @{
                            id = '%QueueID%'
                        }
                    }
                    id                        = 1176
                    name                      = '%Component%'
                    url                       = 'http://lptfs.life.pacificlife.net:8080/tfs/%Collection%/9520fc25-e8c1-40f9-bc0c-b101c093bb36/_apis/build/Definitions/1176'
                    uri                       = 'vstfs:///Build/Definition/1176'
                    path                      = '\'
                    type                      = 'build'
                    queueStatus               = 'enabled'
                    revision                  = 15
                    createdDate               = '2018-08-27T20:33:18.5Z'
                    project                   = @{
                        id          = '9520fc25-e8c1-40f9-bc0c-b101c093bb36'
                        name        = 'WF'
                        description = 'WF (Workflow) Team Project with Agile template'
                        url         = 'http://lptfs.life.pacificlife.net:8080/tfs/%Collection%/_apis/projects/9520fc25-e8c1-40f9-bc0c-b101c093bb36'
                        state       = 'wellFormed'
                        revision    = 1822630
                        visibility  = 'private'
                    }
                }
                "Release" = @{
                    source            = 'userInterface'
                    name              = '%Component%'
                    description       = $null
                    path              = '\'
                    variables         = @{
                        ComponentName = @{
                            value = '%Component%'
                        }
                    }
                    variableGroups    = @(
                        15
                        17
                    )
                    environments      = @(
                        @{
                            id                  = 504
                            name                = 'Dev2'
                            rank                = 1
                            owner               = @{
                                id          = '352e2520-e7a1-4528-80e4-b0d332ae98bc'
                                displayName = 'DeJulia, Michael'
                                uniqueName  = 'PACIFICMUTUAL\mdejulia'
                                url         = 'http://lptfs.life.pacificlife.net:8080/tfs/%Collection%/_apis/Identities/352e2520-e7a1-4528-80e4-b0d332ae98bc'
                                imageUrl    = 'http://lptfs.life.pacificlife.net:8080/tfs/%Collection%/_api/_common/identityImage?id=352e2520-e7a1-4528-80e4-b0d332ae98bc'
                            }
                            variables           = @{
                            }
                            preDeployApprovals  = @{
                                approvals = @(
                                    @{
                                        rank             = 1
                                        isAutomated      = $true
                                        isNotificationOn = $false
                                        id               = 2210
                                    }
                                )
                            }
                            deployStep          = @{
                                tasks = @()
                                id    = 2211
                            }
                            postDeployApprovals = @{
                                approvals = @(
                                    @{
                                        rank             = 1
                                        isAutomated      = $true
                                        isNotificationOn = $false
                                        id               = 2212
                                    }
                                )
                            }
                            deployPhases        = @(
                                @{
                                    deploymentInput = @{
                                        healthPercent             = 0
                                        deploymentHealthOption    = 'Custom'
                                        tags                      = @(
                                            '%Component%'
                                        )
                                        skipArtifactsDownload     = $false
                                        queueId                   = 240
                                        demands                   = @()
                                        enableAccessToken         = $false
                                        timeoutInMinutes          = 0
                                        jobCancelTimeoutInMinutes = 1
                                        condition                 = 'succeeded()'
                                        overrideInputs            = @{
                                        }
                                    }
                                    rank            = 1
                                    phaseType       = 'machineGroupBasedDeployment'
                                    name            = 'IIS Deployment'
                                    workflowTasks   = @(
                                        @{
                                            taskId           = '1ed9aa9e-1c03-4525-a1a5-e5b6e2bd65b7'
                                            version          = '1.*'
                                            name             = 'Task group: Target - Install Web Application'
                                            refName          = 'TargetInstallWebApplication1'
                                            enabled          = $true
                                            alwaysRun        = $true
                                            continueOnError  = $true
                                            timeoutInMinutes = 0
                                            definitionType   = 'metaTask'
                                            overrideInputs   = @{
                                            }
                                            condition        = 'succeededOrFailed()'
                                            inputs           = @{
                                                ParentWebsiteName       = 'PLAWDWebSite'
                                                ApplicationPoolUsername = '$(IISServiceAccountUserName)'
                                                ApplicationPoolPassword = '$(IISServiceAccountPassword)'
                                                WebAppName              = '$(ComponentName)'
                                                WebsiteArtifactLocation = '$(ComponentName)\$(ComponentName)'
                                                FileExtensionToTokenize = ''
                                            }
                                        }
                                    )
                                }
                            )
                            environmentOptions  = @{
                                emailNotificationType   = 'OnlyOnFailure'
                                emailRecipients         = 'release.environment.owner;release.creator'
                                skipArtifactsDownload   = $false
                                timeoutInMinutes        = 0
                                enableAccessToken       = $false
                                publishDeploymentStatus = $true
                            }
                            demands             = @()
                            conditions          = @(
                                @{
                                    name          = 'ReleaseStarted'
                                    conditionType = 'event'
                                    value         = ''
                                }
                            )
                            executionPolicy     = @{
                                concurrencyCount = 0
                                queueDepthCount  = 0
                            }
                            schedules           = @()
                            retentionPolicy     = @{
                                daysToKeep     = 60
                                releasesToKeep = 30
                                retainBuild    = $true
                            }
                            processParameters   = @{
                            }
                            properties          = @{
                            }
                        }
                    )
                    artifacts         = @(
                        @{
                            sourceId            = '%ProjectID%:%BuildDefID%'
                            type                = 'Build'
                            alias               = '%Component%'
                            definitionReference = @{
                                artifactSourceDefinitionUrl = @{
                                    id   = 'http://lptfs.life.pacificlife.net:8080/tfs/_permalink/_build/index?collectionId=c5d08174-c2b8-44ca-8f71-73bfb4bac636&projectId=%ProjectID%&definitionId=%BuildDefID%'
                                    name = ''
                                }
                                defaultVersionBranch        = @{
                                    id   = ''
                                    name = ''
                                }
                                defaultVersionSpecific      = @{
                                    id   = ''
                                    name = ''
                                }
                                defaultVersionTags          = @{
                                    id   = ''
                                    name = ''
                                }
                                defaultVersionType          = @{
                                    id   = 'latestType'
                                    name = 'Latest'
                                }
                                definition                  = @{
                                    id   = '%BuildDefID%'
                                    name = '%Component%'
                                }
                                project                     = @{
                                    id   = '%ProjectID%'
                                    name = '%Project%'
                                }
                            }
                            isPrimary           = $true
                        }
                    )
                    triggers          = @(
                        @{
                            artifactAlias     = '%Component%'
                            triggerConditions = @()
                            triggerType       = 'artifactSource'
                        }
                    )
                    releaseNameFormat = '$(Build.BuildNumber)-$(rev:r)'
                    url               = 'http://lptfs.life.pacificlife.net:8080/tfs/%Collection%/%ProjectID%/_apis/Release/definitions/168'
                    _links            = @{
                        self = @{
                            href = 'http://lptfs.life.pacificlife.net:8080/tfs/%Collection%/%ProjectID%/_apis/Release/definitions/168'
                        }
                        web  = @{
                            href = 'http://lptfs.life.pacificlife.net:8080/tfs/%Collection%/%ProjectID%/_release?definitionId=168'
                        }
                    }
                    comment           = ''
                    tags              = @()
                    properties        = @{
                        'System.EnvironmentRankLogicVersion' = @{
                            '$type'  = 'System.String'
                            '$value' = '2'
                        }
                    }
                }
            }
        }
    }
    Process
    {
        $templateJson = $templates.$TemplateName.$type | ConvertTo-Json -Depth 7
        If ($Type -eq 'Build')
        {
            $queueID = Get-APQueue -Instance $Instance -Collection $Collection -Project $Project -QueueName $QueueName
            $Tokens = @{
                '%Project%'     = $Project
                '%Component%'   = $Component
                '%Collection%'  = $Collection5
                '%QueueID%'     = $queueID.ID
            }
            If($PSCmdlet.ParameterSetName -eq 'DotNetWebsite')
            {
                $Tokens.'%SolutionPath' = $SolutionPath
            }
        }
        If ($Type -eq 'Release')
        {
            $buildData = Get-APBuildDefinitionList -Name $Component -Instance $Instance -Collection $Collection -Project $Project
            $Tokens.'%ProjectID%' = $buildData.Component.id
            $Tokens.'%BuildDefID%' = $buildData.ID
        }      
        $tokens.Keys | ForEach-Object -Process { $templateJson = $templateJson -replace $_, $tokens.Item($_) }
        Write-Output $templateJson
    }
}
