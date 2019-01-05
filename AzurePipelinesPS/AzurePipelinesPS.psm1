# Module Variables
$Script:PSModuleRoot = $PSScriptRoot
$Script:ModuleName = "AzurePipelinesPS"
$Script:ModuleDataRoot = (Join-Path -Path $env:APPDATA -ChildPath $Script:ModuleName)
$Script:ModuleDataPath = (Join-Path -Path $Script:ModuleDataRoot -ChildPath "ModuleData.json")

if (-not (Test-Path $Script:ModuleDataRoot)) {New-Item -ItemType Directory -Path $Script:ModuleDataRoot -Force}

$folders = 'Private', 'Public'
foreach ($folder in $folders)
{
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder
    if (Test-Path -Path $folderPath)
    {
        Write-Verbose -Message "Importing files from [$folder]..."
        $files = Get-ChildItem -Path $folderPath -Filter '*.ps1' -File -Recurse |
            Where-Object Name -notlike '*.Tests.ps1'

        foreach ($file in $files)
        {
            Write-Verbose -Message "Dot sourcing [$($file.BaseName)]..."
            . $file.FullName
        }
    }
}

Write-Verbose -Message 'Exporting Public functions...'
$functions = Get-ChildItem -Path "$PSScriptRoot\Public" -Filter '*.ps1' -File
Export-ModuleMember -Function $functions.BaseName
