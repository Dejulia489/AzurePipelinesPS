$Function = 'Get-ModuleData'
$Script:ModuleName = 'AzureDevOpsPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\$ModuleName.psd1"
$Script:TestDataPath = "$ModuleRoot\Tests\ModuleData.xml"

Describe "Function: [$Function]" {
    Import-Module $ModuleManifestPath -Force
    $moduledata = Get-ADOModuleData -Path $TestDataPath
    Context "[$ModuleName] tests" {
        It 'should return Instance' {
            $moduledata.Instance | Should be 'https://myproject.visualstudio.com/'
        }
        It 'should return Collection' {
            $moduledata.Collection | Should be 'DefaultCollection'
        }
        It 'should return secure Personal Access Token' {
            $type = $moduledata.PersonalAccessToken.GetType() 
            $type.Name | Should be 'SecureString' 
        }
    }
}

