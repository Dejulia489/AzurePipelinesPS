$Script:ModuleName = 'AzurePipelinesPS'
$Script:Folders = 'Private', 'Public', 'Tests'
$Script:Output = Join-Path -Path $BuildRoot -ChildPath 'Output'
$Script:DocsPath = Join-Path -Path $BuildRoot -ChildPath 'Docs'
$Script:Destination = Join-Path -Path $Output -ChildPath $ModuleName
$Script:Source = Join-Path -Path $BuildRoot -ChildPath $ModuleName
$Script:ModulePath = Join-Path -Path $Destination -ChildPath "$ModuleName.psm1"
$Script:ManifestPath = Join-Path -Path $Destination -ChildPath "$ModuleName.psd1"
$Script:TestsPath = Join-Path -Path $Source -ChildPath 'Tests'
$Script:TestFile = "$PSScriptRoot\Output\TestResults.xml"

task Default Build, Test, UpdateSourceManifest
task Build Copy, BuildModule, BuildManifest
task Test Build, ImportModule, FullTests


task Clean {
    Write-Output 'Cleaning Output directories...'
    $null = Get-ChildItem -Path $Output -Directory -Recurse |
        Remove-Item -Recurse -Force -ErrorAction 'Ignore'
}

task Copy {
    Write-Output "Creating Directory [$Destination]..."
    $null = New-Item -ItemType 'Directory' -Path $Destination -ErrorAction 'Ignore'

    $files = Get-ChildItem -Path $Source -File |
        Where-Object 'Name' -notmatch "$ModuleName\.ps[dm]1"

    foreach ($file in $files)
    {
        Write-Output 'Creating [{0}]...' -f $file.Name
        Copy-Item -Path $file.FullName -Destination $Destination -Force
    }

    $directories = Get-ChildItem -Path $Source -Directory |
        Where-Object 'Name' -notin $Folders

    foreach ($directory in $directories)
    {
        Write-Output 'Creating [.{0}]...' -f $directory.Name
        Copy-Item -Path $directory.FullName -Destination $Destination -Recurse -Force
    }
}

task BuildModule @{
    Inputs  = (Get-ChildItem -Path $Source -File -Filter '*.ps1' -Recurse)
    Outputs = $ModulePath
    Jobs    = {
        $sb = [Text.StringBuilder]::new()
        $null = $sb.AppendLine('$Script:PSModuleRoot = $PSScriptRoot')
        $null = $sb.AppendLine("`$Script:ModuleName = 'AzurePipelinesPS'")
        $null = $sb.AppendLine("`$Script:ModuleData = `"$env:APPDATA\$Script:ModuleName`"")
        $null = $sb.AppendLine("`$Script:ModuleDataPath = `"$Script:ModuleData\DefaultServer.xml`"")


        foreach ($folder in $Folders)
        {
            if (Test-Path -Path "$Source\$folder")
            {
                $null = $sb.AppendLine("# Imported from [$Source\$folder]")
                $files = Get-ChildItem -Path "$Source\$folder" -Filter '*.ps1' |
                    Where-Object 'Name' -notlike '*.Tests.ps1'

                foreach ($file in $files)
                {
                    $name = $file.Name

                    "Importing [$name]..."
                    $null = $sb.AppendLine("# $name")
                    $null = $sb.AppendLine([IO.File]::ReadAllText($file.FullName))
                }
            }
        }

        Write-Output "Creating Module [$ModulePath]..."
        Set-Content -Path  $ModulePath -Value $sb.ToString() -Encoding 'UTF8'
    }
}

task BuildManifest @{
    Inputs  = (Get-ChildItem -Path $Source -Recurse -File)
    Outputs = $ManifestPath
    Jobs = {
        Write-Output "Building [$ManifestPath]..."
        Copy-Item -Path "$Source\$ModuleName.psd1" -Destination $ManifestPath

        $functions = Get-ChildItem -Path "$ModuleName\Public\*.ps1" -ErrorAction 'Ignore' |
            Where-Object 'Name' -notlike '*.Tests.ps1'

        if ($env:BUILD_BUILDNUMBER)
        {
            Write-Output "Located Azure Pipelines build number, updating [$ManifestPath]..."
            Update-ModuleManifest -Path $ManifestPath -FunctionsToExport $functions.BaseName -ModuleVersion $env:BUILD_BUILDNUMBER
        }
        else
        {
            Write-Output "Updating [$ManifestPath]..."
            Update-ModuleManifest -Path $ManifestPath -FunctionsToExport $functions.BaseName
        }
    }
}

task ImportModule {
    if (-not(Test-Path -Path $ManifestPath))
    {
        Write-Output "Module [$ModuleName] is not built; cannot find [$ManifestPath]."
        Write-Error "Could not find module manifest [$ManifestPath]. You may need to build the module first." -ErrorAction Stop
    }
    else
    {
        $loaded = Get-Module -Name $ModuleName -All
        if ($loaded)
        {
            Write-Output "Unloading Module [$ModuleName] from a previous import..."
            $loaded | Remove-Module -Force
        }

        Write-Output "Importing Module [$ModuleName] from [$ManifestPath]..."
        Import-Module -FullyQualifiedName $ManifestPath -Force
    }
}

task FullTests {
    $params = @{
        CodeCoverage           = 'Output\*\*.psm1'
        CodeCoverageOutputFile = 'Output\codecoverage.xml'
        OutputFile             = $testFile
        OutputFormat           = 'NUnitXml'
        PassThru               = $true
        Path                   = $Script:TestsPath
        Show                   = 'Failed', 'Fails', 'Summary'
    }

    $results = Invoke-Pester @params
    if ($results.FailedCount -gt 0)
    {
        Write-Error "Failed [$($results.FailedCount)] Pester tests." -ErrorAction Stop
    }
}

task UpdateSourceManifest {
    Copy-Item -Path $ManifestPath -Destination "$Source\$ModuleName.psd1"
}

