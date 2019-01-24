$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.json"
Import-Module $ModuleManifestPath -Force
InModuleScope $ModuleName {
    #region testParams
    $Function = 'Add-APVariableGroup'
    $newApSessionSplat = @{
        Collection          = 'myCollection'
        Project             = 'myProject'
        Instance            = 'https://dev.azure.com/'
        PersonalAccessToken = 'myToken'
        ApiVersion          = '5.0-preview'
        SessionName         = 'ADOmyProject'
    }
    $session = New-APSession @newApSessionSplat
    $_name = 'myNewPool'
    $_variables = @{ myKey = 'myValue' }
    $_uri = 'https://dev.azure.com/myCollection/myProject/_apis/distributedtask/variablegroups/?api-version=5.0-preview'
    $_apiEndpoint = 'distributedtask-variablegroups'
    $_description = 'myDescription'
    #endregion testParams

    Describe "Function: [$Function]" {   
        Mock -CommandName Get-APApiEndpoint -ParameterFilter { $ApiType -eq $_apiEndpoint } -MockWith {
            Return $_apiEndpoint
        }
        Mock -CommandName Set-APUri -MockWith {
            Return $_uri
        }
        Context 'Description' {
            Mock -CommandName Invoke-APRestMethod -ParameterFilter { $Body.Description -eq $_description } -MockWith {
                Return $_description
            } 
            It 'should update the description' {
                Add-APVariableGroup -Session $session -Name $_name -Variables $_variables -Description $_description | Should be $_description
                Assert-MockCalled -CommandName 'Get-APApiEndpoint' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Set-APUri' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Invoke-APRestMethod' -Times 1 -Exactly
            }
        }
        Context 'Name' {
            Mock -CommandName Invoke-APRestMethod -ParameterFilter { $Uri.AbsoluteUri -eq $_uri } -MockWith {
                Return 'Mocked Invoke-APRestMethod'
            }
            It 'should accept session' {
                Add-APVariableGroup -Session $session -Name $_name -Variables $_variables | Should be 'Mocked Invoke-APRestMethod'
                Assert-MockCalled -CommandName 'Get-APApiEndpoint' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Set-APUri' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Invoke-APRestMethod' -Times 1 -Exactly
            }
        }
    }
    $session | Remove-APSession
}


