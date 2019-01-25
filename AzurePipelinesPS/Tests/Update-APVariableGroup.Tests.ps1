$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.json"
Import-Module $ModuleManifestPath -Force
InModuleScope $ModuleName {
    #region testParams
    $Function = 'Update-APVariableGroup'
    $newApSessionSplat = @{
        Collection          = 'myCollection'
        Project             = 'myProject'
        Instance            = 'https://dev.azure.com/'
        PersonalAccessToken = 'myToken'
        ApiVersion          = '5.0-preview'
        SessionName         = 'ADOmyProject'
    }
    $session = New-APSession @newApSessionSplat
    $template = @{ definition = 'myDefinitions'}
    $_groupId = 7
    $_name = 'myGroup'
    $_uri = ('https://dev.azure.com/myCollection/myProject/_apis/distributedtask/variablegroups/{0}?api-version=5.0-preview' -f $_groupId)
    $_apiEndpoint = 'distributedtask-VariableGroupId'
    #endregion testParams

    Describe "Function: [$Function]" -Tag 'Pending' {   
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
                Update-APVariableGroup -Session $session -GroupId $_groupId -Name $_name | Should be 'Mocked Invoke-APRestMethod'
                Assert-MockCalled -CommandName 'Get-APApiEndpoint' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Set-APUri' -Times 2 -Exactly
                Assert-MockCalled -CommandName 'Invoke-APRestMethod' -Times 2 -Exactly
            }
        }
    }
    $session | Remove-APSession
}


