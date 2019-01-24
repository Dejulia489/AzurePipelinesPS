$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.json"
InModuleScope $ModuleName {
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
        Import-Module $ModuleManifestPath -Force
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
            Return
        }
        Mock -CommandName Get-APSession -MockWith {
            Return
        }
        Mock -CommandName Remove-APSession -MockWith {
            Return
        }
        $session = New-APSession @splat2 
        It 'should save session to disk' {
            $session[0] | Save-APSession -Path $TestDataPath
        }
        It 'should not overwrtie saved sessions on disk' {
            $session[0] | Save-APSession -Path $TestDataPath
        }
    }
}