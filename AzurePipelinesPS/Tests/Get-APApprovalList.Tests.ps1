$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.json"
Import-Module $ModuleManifestPath -Force
InModuleScope $ModuleName {
    #region testParams
    $Function = 'Get-APApprovalList'
    $newApSessionSplat = @{
        Collection          = 'myCollection'
        Project             = 'myProject'
        Instance            = 'https://dev.azure.com/'
        PersonalAccessToken = 'myToken'
        ApiVersion          = '5.0-preview'
        SessionName         = 'ADOmyProject'
    }
    $session = New-APSession @newApSessionSplat
    $_uri = 'https://dev.azure.com/myCollection/myProject/_apis/distributedtask/variablegroups/?api-version=5.0-preview'
    $_apiEndpoint = 'release-approvals'
    #endregion testParams

    Describe "Function: [$Function]" {
        Mock -CommandName Get-APApiEndpoint -ParameterFilter { $ApiType -eq $_apiEndpoint } -MockWith {
            return $_apiEndpoint
        }
        Mock -CommandName Set-APUri -MockWith {
            return $_uri
        }
<#         Context 'Session' {
            Mock -CommandName Invoke-APWebRequest -MockWith {
                return 'Mocked Invoke-APWebRequest'
            }
            It 'should accept session' {
                Get-APApprovalList -Session $session | Should be 'Mocked Invoke-APWebRequest'
                Assert-MockCalled -CommandName 'Get-APApiEndpoint' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Set-APUri' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Invoke-APWebRequest' -Times 1 -Exactly
            }
        } #>
    }
    $session | Remove-APSession
}


