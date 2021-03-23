$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.json"
Import-Module $ModuleManifestPath -Force
InModuleScope $ModuleName {
    #region testParams
    $Function = 'Add-APDeploymentGroup'
    $newApSessionSplat = @{
        Collection          = 'myCollection'
        Project             = 'myProject'
        Instance            = 'https://dev.azure.com/'
        PersonalAccessToken = 'myToken'
        ApiVersion          = '5.0-preview'
        SessionName         = 'ADOmyProject'
    }
    $session = New-APSession @newApSessionSplat
    $poolName = 'myNewPool'
    $_uri = 'https://dev.azure.com/myCollection/myProject/distributedtask-deploymentGroupId?api-version=5.0-preview'
    $_apiEndpoint = 'distributedtask-deploymentGroupId'
    $description = 'myGroupsDescription'
    $poolId = 7
    #endregion testParams
    
    Describe "Function: [$Function]" {
        Mock -CommandName Get-APApiEndpoint -ParameterFilter { $ApiType -eq $_apiEndpoint } -MockWith {
            return $_apiEndpoint
        }
        Mock -CommandName Set-APUri -MockWith {
            return $_uri
        }
        Context 'Description' {
            Mock -CommandName Invoke-APRestMethod -ParameterFilter { $Body.Description -eq $description } -MockWith {
                return $description
            } 
            It 'should update the description' {
                Add-APDeploymentGroup -Session $session -Name $poolName -Description $description | Should be $description
                Assert-MockCalled -CommandName 'Get-APApiEndpoint' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Set-APUri' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Invoke-APRestMethod' -Times 1 -Exactly
            }
        }
        Context 'PoolId' {
            Mock -CommandName Invoke-APRestMethod -ParameterFilter { $Body.PoolId -eq $poolId } -MockWith {
                return $poolId
            } 
            It 'should update the pool Id' {
                Add-APDeploymentGroup -Session $session -Name $poolName -PoolId $poolId | Should be $poolId
                Assert-MockCalled -CommandName 'Get-APApiEndpoint' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Set-APUri' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Invoke-APRestMethod' -Times 1 -Exactly
            }
        }
        Context 'Session' {
            Mock -CommandName Invoke-APRestMethod -ParameterFilter { $Uri.AbsoluteUri -eq $_uri } -MockWith {
                return 'Mocked Invoke-APRestMethod'
            }
            It 'should accept session' {
                Add-APDeploymentGroup -Name $poolName -Session $session | Should be 'Mocked Invoke-APRestMethod'
                Assert-MockCalled -CommandName 'Get-APApiEndpoint' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Set-APUri' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Invoke-APRestMethod' -Times 1 -Exactly
            }
        }
    }
    $session | Remove-APSession
}


