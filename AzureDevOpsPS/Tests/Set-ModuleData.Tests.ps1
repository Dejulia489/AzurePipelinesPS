$Function = 'Set-ModuleData'
$Script:ModuleName = 'AzureDevOpsPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.xml"
$moduleData = @{
    Instance            = 'https://myproject.visualstudio.com/'
    Collection          = 'DefaultCollection'
    PersonalAccessToken = 'myPatToken' 
}

Describe "Function: [$Function]" {
    Import-Module $ModuleManifestPath -Force
    @{} | Export-Clixml -Path $TestDataPath
    Context "[$ModuleName] tests" {
        It 'sets Instance' {
            Set-ADOModuleData -Instance $moduledata.Instance -Path $TestDataPath
            $moduleDataReturned = Get-ADOModuleData -Path $TestDataPath
            $moduleDataReturned.Instance | Should be $moduledata.Instance
        }
        It 'sets Collection' {
            Set-ADOModuleData -Collection $moduleData.Collection -Path $TestDataPath
            $moduleDataReturned = Get-ADOModuleData -Path $TestDataPath
            $moduleDataReturned.Collection | Should be $moduleData.Collection
        }
        It 'encrypts Personal Access Token' {
            Set-ADOModuleData -PersonalAccessToken $moduleData.PersonalAccessToken -Path $TestDataPath
            $moduleDataReturned = Get-ADOModuleData -Path $TestDataPath
            $type = $moduleDataReturned.PersonalAccessToken.GetType() 
            $type.Name | Should be 'SecureString' 
        }
    }
}