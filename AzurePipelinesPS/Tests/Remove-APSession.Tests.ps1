$Function = 'Remove-APSession'
$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.json"
Describe "Function: [$Function]" {   
    Import-Module $ModuleManifestPath -Force
    Mock -CommandName Get-APSession -ParameterFilter {$id -eq 0} -MockWith {
        New-Object -TypeName PSCustomObject -Property @{
            Collection          = 'myCollection1'
            Project             = 'myProject1'
            Instance            = 'https://dev.azure.com/'
            PersonalAccessToken = (ConvertTo-SecureString -Force -AsPlainText -String 'myToken1')
            Version             = 'vNext'
            SessionName         = 'mySession1'
            Id                  = 0
        }
        Return
    }
    Mock -CommandName Get-APSession -ParameterFilter {$id -eq 1} -MockWith {
        New-Object -TypeName PSCustomObject -Property @{
            Collection          = 'myCollection2'
            Project             = 'myProject2'
            Instance            = 'https://dev.azure.com/'
            PersonalAccessToken = (ConvertTo-SecureString -Force -AsPlainText -String 'myToken2')
            Version             = 'vNext'
            SessionName         = 'mySession2'
            Id                  = 1
            Saved               = $true
        }
        Return
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
        Return
    }
    It 'should accept pipeline input' {
        {Get-APSession -Id 0 -Path $TestDataPath | Remove-APSession} | Should not throw
    }
    It 'should remove a saved session from disk' {
        $sessions = Get-APSession -Id 1 -Path $TestDataPath
        $sessions | Save-APSession -Path $TestDataPath
        {$sessions | Remove-APSession -Path $TestDataPath} | Should not throw
    } 
}

