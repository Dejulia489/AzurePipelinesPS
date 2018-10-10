$Function = 'Get-APSession'
$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.json"
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
    $Global:_APSessions = $null 
    $Global:_APSessions = @()
    Mock -CommandName New-APSession -MockWith {
        $_session1 = New-Object -TypeName PSCustomObject -Property @{
            Collection          = 'myCollection1'
            Project             = 'myProject1'
            Instance            = 'https://dev.azure.com/'
            PersonalAccessToken = (ConvertTo-SecureString -Force -AsPlainText -String 'myToken1')
            Version             = 'vNext'
            SessionName         = 'mySession1'
            Id                  = 0
        }
        $_session2 = New-Object -TypeName PSCustomObject -Property @{
            Collection          = 'myCollection2'
            Project             = 'myProject2'
            Instance            = 'https://dev.azure.com/'
            PersonalAccessToken = (ConvertTo-SecureString -Force -AsPlainText -String 'myToken2')
            Version             = 'vNext'
            SessionName         = 'mySession2'
            Id                  = 1
        }
        $Global:_APSessions += $_session1
        $Global:_APSessions += $_session2
        Return $Global:_APSessions
    }
    Mock -CommandName Save-APSession -MockWith {
        $data = @{SessionData = @()}
        $_object = @{
            Collection          = 'myCollection1'
            Project             = 'myProject1'
            Instance            = 'https://dev.azure.com/'
            PersonalAccessToken = 'myToken1'
            Version             = 'vNext'
            SessionName         = 'mySession1'
            Saved               = $true
            Id                  = 0
        }
        If ($Session.PersonalAccessToken)
        {
            $_object.PersonalAccessToken = ($Session.PersonalAccessToken | ConvertFrom-SecureString) 
        }
        $data.SessionData += $_object
        $data | Convertto-Json -Depth 5 | Out-File -FilePath $TestDataPath
        $session | Remove-APSession
    }
    Mock -CommandName Remove-APSession -MockWith {
        Return
    }
    $session = New-APSession @splat2 
    # Save the first session with an Id of 0
    $session[0] | Save-APSession
    $sessions = Get-APSession -Path $TestDataPath
    It 'should save session to disk' {
        Get-Content $TestDataPath -Raw | Should not be $null
    }
    It 'should return saved and unsaved sessions' {
        $sessions.count | should be 2
    }
    It 'should get saved session by id' {
        (Get-APSession -Id 0 -Path $TestDataPath).Saved | Should be $true
    }
    It 'should get unsaved session by id' {
        (Get-APSession -Id $session[0].id -Path $TestDataPath).id | Should be $session[0].Id
        (Get-APSession -Id $session[1].id -Path $TestDataPath).id | Should be $session[1].Id
    }
    It 'should get session by session name' {
        (Get-APSession -SessionName $session[0].SessionName -Path $TestDataPath).SessionName | Should be $session[0].SessionName
        (Get-APSession -SessionName $session[1].SessionName -Path $TestDataPath).SessionName | Should be $session[1].SessionName
    }
    It 'should accept pipeline input' {
        $session | Get-APSession -Path $TestDataPath | Should not be NullOrEmpty
    }
    It 'should return a secure personal access token' {
        $session[0].PersonalAccessToken.GetType().Name | Should be SecureString
    }
}

