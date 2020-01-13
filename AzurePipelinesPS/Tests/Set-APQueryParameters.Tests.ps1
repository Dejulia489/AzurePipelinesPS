$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
$Script:TestDataPath = "TestDrive:\ModuleData.json"
Import-Module $ModuleManifestPath -Force
InModuleScope $ModuleName {
    #region testParams
    $Function = 'Set-APQueryParameters'
    #endregion testParams

    Describe "Function: [$Function]" {
        Context '$-prefixed query parameters' {
            'Mine', 'Top', 'Expand' | ForEach-Object {
                It "${_} should be converted to `$${_}" {
                    &$Function -InputObject @{$_ = 'value'} | Should -Be "`$${_}=value"
                }
            }
        }
    }
}
