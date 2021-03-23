$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.json"
Import-Module $ModuleManifestPath -Force
InModuleScope $ModuleName {
    #region testParams
    $Function = 'Update-APReleaseEnvironment'
    $newApSessionSplat = @{
        Collection          = 'myCollection'
        Project             = 'myProject'
        Instance            = 'https://dev.azure.com/'
        PersonalAccessToken = 'myToken'
        ApiVersion          = '5.0-preview'
        SessionName         = 'ADOmyProject'
    }
    $session = New-APSession @newApSessionSplat
    $_releaseId = 7 
    $_environmentId = 8
    $_status = 'inProgress'
    $_uri = ('https://dev.azure.com/myCollection/myProject/_apis/release/releases/{0}/environments/{1}?api-version=5.0-preview' -f $_releaseId, $_environmentId)
    $_apiEndpoint = 'release-environmentId'
    #endregion testParams

    Describe "Function: [$Function]" {   
        Mock -CommandName Get-APApiEndpoint -ParameterFilter { $ApiType -eq $_apiEndpoint } -MockWith {
            return $_apiEndpoint
        }
        Mock -CommandName Set-APUri -MockWith {
            return $_uri
        }
        Context 'Session' {
            Mock -CommandName Invoke-APRestMethod -ParameterFilter { $Uri.AbsoluteUri -eq $_uri } -MockWith {
                return 'Mocked Invoke-APRestMethod'
            }
            It 'should accept session' {
                Update-APReleaseEnvironment -Session $session -ReleaseId $_releaseId -EnvironmentId $_environmentId -Status $_status | Should be 'Mocked Invoke-APRestMethod'
                Assert-MockCalled -CommandName 'Get-APApiEndpoint' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Set-APUri' -Times 1 -Exactly
                Assert-MockCalled -CommandName 'Invoke-APRestMethod' -Times 1 -Exactly
            }
        }
    }
    $session | Remove-APSession
}


