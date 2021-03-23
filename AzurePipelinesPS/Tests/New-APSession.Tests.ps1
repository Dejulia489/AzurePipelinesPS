$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.json"
Import-Module $ModuleManifestPath -Force
InModuleScope $ModuleName {
    #region testParams
    $Function = 'New-APSession'
    $newApSessionSplat = @{
        Collection          = 'myCollection'
        Project             = 'myProject'
        Instance            = 'https://dev.azure.com/'
        PersonalAccessToken = 'myToken'
        ApiVersion          = '5.0-preview'
        SessionName         = 'ADOmyProject'
    }
    #endregion testParams

    Describe "Function: [$Function]" {
        $Global:_APSessions = $null 
        Mock -CommandName Get-APSession -MockWith {
            return
        }
        Context 'Collection' {
            It 'should return collection' {
                (New-APSession @newApSessionSplat).Collection | Should be $newApSessionSplat.Collection
                Assert-MockCalled -CommandName 'Get-APSession' -Times 1 -Exactly
                $Global:_APSessions = $null 
            }
        }
        Context 'Project' {
            It 'should return project' {
                (New-APSession @newApSessionSplat).Project | Should be $newApSessionSplat.Project
                Assert-MockCalled -CommandName 'Get-APSession' -Times 1 -Exactly
                $Global:_APSessions = $null 
            }
        }
        Context 'Instance' {
            It 'should return instance' {
                (New-APSession @newApSessionSplat).Instance | Should be $newApSessionSplat.Instance
                Assert-MockCalled -CommandName 'Get-APSession' -Times 1 -Exactly
                $Global:_APSessions = $null 
            }
        }
        Context 'Api version' {
            It 'should return api version' {
                (New-APSession @newApSessionSplat).ApiVersion | Should be $newApSessionSplat.ApiVersion
                Assert-MockCalled -CommandName 'Get-APSession' -Times 1 -Exactly
                $Global:_APSessions = $null 
            }
        }
        Context 'Session name' {
            It 'should return session name' {
                (New-APSession @newApSessionSplat).SessionName | Should be $newApSessionSplat.SessionName
                Assert-MockCalled -CommandName 'Get-APSession' -Times 1 -Exactly
                $Global:_APSessions = $null 
            }
        }
        Context 'Personal access token' {
            It 'should return personal access token' {
                (New-APSession @newApSessionSplat).PersonalAccessToken.GetType() | Should be 'securestring'
                Assert-MockCalled -CommandName 'Get-APSession' -Times 1 -Exactly
                $Global:_APSessions = $null 
            }
        }
    }
}


