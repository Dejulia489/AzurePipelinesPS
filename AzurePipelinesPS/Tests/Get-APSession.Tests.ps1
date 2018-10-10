$Function = 'Get-APSession'
$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.json"
$splat1 = @{
    Collection          = 'myCollection1'
    Project             = 'myProject1'
    Instance            = 'https://dev.azure.com/'
    PersonalAccessToken = 'myToken1'
    Version             = 'vNext'
    SessionName         = 'mySession1'
    Saved               = $true
}

$splat2 = @{
    Collection          = 'myCollection2'
    Project             = 'myProject2'
    Instance            = 'https://dev.azure.com/'
    PersonalAccessToken = 'myToken2'
    Version             = 'vNext'
    SessionName         = 'mySession2'
}

Describe "Function: [$Function]" {
    Import-Module $ModuleManifestPath -Force
    $session = New-APSession @splat2 
    $sessions = Get-APSession -Path $TestDataPath
    It 'should return saved and unsaved sessions' -Pending {
        $sessions.count | should be 2
    }
    It 'should get saved session by id' -Pending {
        (Get-APSession -Id 0).Saved | Should be $true
    }
    It 'should get unsaved session by id' {
        (Get-APSession -Id $session.id).id | Should be $session.Id
    }
    It 'should accept pipeline input' {
        $session | Get-APSession | Should not be NullOrEmpty
    }
    It 'should return a secure personal access token' {
        $session.PersonalAccessToken.GetType().Name | Should be SecureString
    }
}

