$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
Import-Module $ModuleManifestPath -Force
InModuleScope $ModuleName {
    $testDataPath = "TestDrive:\ModuleData.json"
    #region testParams
    $Function = 'Save-APSession'
    $splat2 = @{
        Collection          = 'myCollection2'
        Project             = 'myProject2'
        Instance            = 'https://dev.azure.com/'
        PersonalAccessToken = 'myToken2'
        ApiVersion          = '5.0-preview'
        SessionName         = 'mySession2'
    }
    #endregion testParams
    Describe "Function: [$Function]" {
        Mock -CommandName New-APSession -MockWith {
            New-Object -TypeName PSCustomObject -Property @{
                Collection          = 'myCollection1'
                Project             = 'myProject1'
                Instance            = 'https://dev.azure.com/'
                PersonalAccessToken = (ConvertTo-SecureString -Force -AsPlainText -String 'myToken1')
                ApiVersion          = '5.0-preview'
                SessionName         = 'mySession1'
                Id                  = 0
            }
            New-Object -TypeName PSCustomObject -Property @{
                Collection          = 'myCollection2'
                Project             = 'myProject2'
                Instance            = 'https://dev.azure.com/'
                PersonalAccessToken = (ConvertTo-SecureString -Force -AsPlainText -String 'myToken2')
                ApiVersion          = '5.0-preview'
                SessionName         = 'mySession2'
                Id                  = 1
            }
            return
        }
        Mock -CommandName Get-APSession -MockWith {
            return
        }
        Mock -CommandName Remove-APSession -MockWith {
            return
        }
        It 'should save session to disk' {
            $session = New-APSession @splat2 # splat2 fufills the required parameters but the command is mocked so the output will return the mock
            $session[0] | Save-APSession -Path $testDataPath
        }
        It 'should not overwrtie saved sessions on disk' {
            $session = New-APSession @splat2  # splat2 fufills the required parameters but the command is mocked so the output will return the mock
            $session[0] | Save-APSession -Path $testDataPath
        }
    }
}