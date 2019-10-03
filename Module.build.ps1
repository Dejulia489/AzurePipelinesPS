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

task Default Clean, Build, Test, UpdateSourceManifest
task Build Copy, BuildModule, BuildManifest
task Test ImportModule, FullTests


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
        Write-Output "Creating [$($file.Name)]..."
        Copy-Item -Path $file.FullName -Destination $Destination -Force
    }

    $directories = Get-ChildItem -Path $Source -Directory |
        Where-Object 'Name' -notin $Folders

    foreach ($directory in $directories)
    {
        Write-Output "Creating [$($directory.Name)]..."
        Copy-Item -Path $directory.FullName -Destination $Destination -Recurse -Force
    }
}

task BuildModule @{
    Inputs  = (Get-ChildItem -Path $Source -File -Filter '*.ps1' -Recurse)
    Outputs = $ModulePath
    Jobs    = {
        $sb = [Text.StringBuilder]::new()
        [void] $sb.AppendLine('$Script:PSModuleRoot = $PSScriptRoot')
        [void] $sb.AppendLine('$Script:ModuleName = "AzurePipelinesPS"')
        [void] $sb.AppendLine('$Script:APAppDataPath = [Environment]::GetFolderPath(''ApplicationData'')')
        [void] $sb.AppendLine('$Script:ModuleDataRoot = (Join-Path -Path $Script:APAppDataPath -ChildPath $Script:ModuleName)')
        [void] $sb.AppendLine('$Script:ModuleDataPath = (Join-Path -Path $Script:ModuleDataRoot -ChildPath "ModuleData.json")')
        [void] $sb.AppendLine('if (-not (Test-Path $Script:ModuleDataRoot)) {New-Item -ItemType Directory -Path $Script:ModuleDataRoot -Force}')

        foreach ($folder in $Folders)
        {
            if (Test-Path -Path "$Source\$folder")
            {
                [void] $sb.AppendLine("# Imported from [$Source\$folder]")
                $files = Get-ChildItem -Path "$Source\$folder\*" -Filter '*.ps1' -Exclude '*.Tests.ps1', '*.Pending.ps1'

                foreach ($file in $files)
                {
                    $name = $file.Name

                    "Importing [$name]..."
                    [void] $sb.AppendLine("# $name")
                    [void] $sb.AppendLine([IO.File]::ReadAllText($file.FullName))
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
    Jobs    = {
        Write-Output "Building [$ManifestPath]..."
        Copy-Item -Path "$Source\$ModuleName.psd1" -Destination $ManifestPath

        $functions = Get-ChildItem -Path "$ModuleName\Public\*" -Filter '*.ps1' -Exclude '*.Tests.ps1', '*.Pending.ps1'

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
    Write-Output "Executing tests from [$Script:TestsPath]..."
    $params = @{
        OutputFile   = $testFile
        OutputFormat = 'NUnitXml'
        Path         = $Script:TestsPath
        Show         = 'All'
    }

    Invoke-Pester @params
}

task UpdateSourceManifest {
    Copy-Item -Path $ManifestPath -Destination "$Source\$ModuleName.psd1"
}

task Install {
    $version = [version] (Get-Metadata -Path $ManifestPath -PropertyName 'ModuleVersion')
    $path = $env:PSModulePath.Split(';') | Select-Object -First 1
    if ($path -and (Test-Path -Path $path))
    {
        $path = Join-Path -Path $path -ChildPath $ModuleName
        $path = Join-Path -Path $path -ChildPath $version

        Write-Output "Creating directory at [$path]"
        $null = New-Item -Path $path -ItemType 'Directory' -Force -ErrorAction 'Ignore'

        Write-Output "Copying items from [$Destination] to [$path]"
        Copy-Item -Path "$Destination\*" -Destination $path -Recurse -Force
    }
}

task Uninstall {
    Write-Output 'Removing module from session'
    Get-Module -Name $ModuleName -ErrorAction 'Ignore' | Remove-Module
    $modules = Get-Module $ModuleName -ErrorAction 'Ignore' -ListAvailable
    foreach ($module in $modules)
    {
        Write-Output "Uninstalling [$($module.Name)] version [$($module.Version)]"
        Uninstall-Module -Name $module.Name -RequiredVersion $module.Version -Force
    }
    Write-Output 'Removing manually installed Modules'
    $path = $env:PSModulePath.Split(';') | Select-Object -First 1
    $path = Join-Path -Path $path -ChildPath $ModuleName
    If ($path -and (Test-Path -Path $path))
    {
        Write-Output 'Removing folders'
        Remove-Item $path -Recurse -Force
    }
}

task Analyze {
    Write-Output "Analyzing [$ModulePath]"
    $invokeScriptAnalyzerSplat = @{
        Path     = $ModulePath
        Settings = "$BuildRoot\ScriptAnalyzerSettings.psd1"
        Severity = 'Warning'
    }
    $results = Invoke-ScriptAnalyzer @invokeScriptAnalyzerSplat
    If ($results)
    {
        $results | Format-Table
    }
}
