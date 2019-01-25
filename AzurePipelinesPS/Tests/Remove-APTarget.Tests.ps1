$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.json"
Import-Module $ModuleManifestPath -Force
InModuleScope $ModuleName {
    #region testParams
    $Function = 'Remove-APTarget'
    $newApSessionSplat = @{
        Collection          = 'myCollection'
        Project             = 'myProject'
        Instance            = 'https://dev.azure.com/'
        PersonalAccessToken = 'myToken'
        ApiVersion          = '5.0-preview'
        SessionName         = 'ADOmyProject'
    }
    $session = New-APSession @newApSessionSplat
    $_deploymentGroupId = 7 
    $_targetId = 8
    $_uri = ('https://dev.azure.com/myCollection/myProject/_apis/distributedtask/deploymentgroups/{0}/targets/{1}?api-version=5.0-preview' -f $_deploymentGroupId, $_targetId)
    $_apiEndpoint = 'distributedtask-targetId'
    #endregion testParams

    Describe "Function: [$Function]" {   
        Mock -CommandName Get-APApiEndpoint -ParameterFilter { $ApiType -eq $_apiEndpoint } -MockWith {
            Return $_apiEndpoint
        }
        Mock -CommandName Set-APUri -MockWith {
            Return $_uri
        }
        Context 'Session' {
            Mock -CommandName Invoke-APRestMethod -ParameterFilter { $Uri.AbsoluteUri -eq $_uri } -MockWith {
                Return 'Mocked Invoke-APRestMethod'
            }
            It 'should accept session' {
                Remove-APTarget -Session $session -DeploymentGroupId $_deploymentGroupId -TargetId $_targetId | Should be 'Mocked Invoke-APRestMethod'
                Assert-MockCalled -CommandName 'Get-APApiEndpoint' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Set-APUri' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Invoke-APRestMethod' -Times 1 -Exactly
            }
        }
    }
    $session | Remove-APSession
}


