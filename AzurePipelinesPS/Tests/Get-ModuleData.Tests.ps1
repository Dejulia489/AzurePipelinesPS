$Function = 'Get-ModuleData'
$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.xml"
$moduleData = @{
    Instance            = 'https://myproject.visualstudio.com/'
    Collection          = 'DefaultCollection'
    PersonalAccessToken = 'myPatToken' 
}

Describe "Function: [$Function]" {
    Set-APModuleData @moduleData -Path $TestDataPath 
    Import-Module $ModuleManifestPath -Force
    $moduledataReturned = Get-APModuleData -Path $TestDataPath
    Context "[$ModuleName] tests" {
        It 'should return Instance' {
            $moduledataReturned.Instance | Should be $moduleData.Instance
        }
        It 'should return Collection' {
            $moduledataReturned.Collection | Should be $moduledata.Collection
        }
        It 'should return secure Personal Access Token' {
            $type = $moduledataReturned.PersonalAccessToken.GetType() 
            $type.Name | Should be 'SecureString' 
        }
    }
}

