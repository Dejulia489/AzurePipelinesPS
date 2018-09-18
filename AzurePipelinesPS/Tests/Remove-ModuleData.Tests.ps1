$Function = 'Remove-ModuleData'
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
    Import-Module $ModuleManifestPath -Force
    $moduleData | Export-Clixml -Path $TestDataPath
    Context "[$ModuleName] tests" {
        It 'removes Instance' {
            Remove-APModuleData -Instance -Path $TestDataPath
            $moduleData = Get-APModuleData -Path $TestDataPath
            $moduledata.Instance | Should BeNullOrEmpty
        }
        It 'removes Collection' {
            Remove-APModuleData -Collection -Path $TestDataPath
            $moduleData = Get-APModuleData -Path $TestDataPath
            $moduleData.Collection | Should BeNullOrEmpty
        }
        It 'removes Personal Access Token' {
            Remove-APModuleData -PersonalAccessToken -Path $TestDataPath
            $moduleData = Get-APModuleData -Path $TestDataPath
            $moduleData.PersonalAccessToken | Should BeNullOrEmpty
        }
        It "returns nothing" {
            Remove-APModuleData -PersonalAccessToken -Path $TestDataPath | Should BeNullOrEmpty
        }
    }
}