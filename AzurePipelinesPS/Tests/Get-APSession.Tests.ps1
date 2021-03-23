$Script:ModuleName = 'AzurePipelinesPS'
$Script:ModuleRoot = Split-Path -Path $PSScriptRoot -Parent
$Script:ModuleManifestPath = "$ModuleRoot\..\Output\$ModuleName\$ModuleName.psd1"
Import-Module $ModuleManifestPath -Force
InModuleScope $ModuleName {
    #region testParams
    $Function = 'Get-APSession'
    $splat2 = @{
        Collection          = 'myCollection2'
        Project             = 'myProject2'
        Instance            = 'https://dev.azure.com/'
        PersonalAccessToken = 'myToken2'
        ApiVersion          = '5.0-preview'
        SessionName         = 'myParamSession'
    }
    $_testDataPath = "TestDrive:\ModuleData.json"
    $sessionName = 'mySaveMockSession1'
    $id = 0
    #endregion testParams

    Describe "Function: [$Function]" {   
        $Global:_APSessions = $null 
        Mock -CommandName New-APSession -MockWith {
            New-Object -TypeName PSCustomObject -Property @{
                Collection          = 'myCollection'
                Project             = 'myProject'
                Instance            = 'https://dev.azure.com/'
                PersonalAccessToken = (ConvertTo-SecureString -Force -AsPlainText -String 'myToken1')
                ApiVersion          = '5.0-preview'
                SessionName         = 'myNewMockSession1'
                Id                  = 0
            }
        }
        Mock -CommandName Save-APSession -MockWith {
            $data = @{SessionData = @() }
            $data.SessionData += @{
                Collection          = 'myCollection'
                Project             = 'myProject'
                Instance            = 'https://dev.azure.com/'
                PersonalAccessToken = (ConvertTo-SecureString -String 'myToken' -Force -AsPlainText | ConvertFrom-SecureString)
                ApiVersion          = '5.0-preview'
                SessionName         = 'mySaveMockSession1'
                Saved               = $true
                Id                  = 0
            }
            $data.SessionData += @{
                Collection          = 'myCollection'
                Project             = 'myProject'
                Instance            = 'https://dev.azure.com/'
                PersonalAccessToken = (ConvertTo-SecureString -String 'myToken' -Force -AsPlainText | ConvertFrom-SecureString)
                ApiVersion          = '5.0-preview'
                SessionName         = 'mySaveMockSession2'
                Saved               = $true
                Id                  = 1
            }
            $data | Convertto-Json -Depth 5 | Out-File -FilePath $_testDataPath
        }
        Mock -CommandName Remove-APSession -MockWith {
            return
        }
        # Create and save sessions to test against
        $_newSessions = New-APSession @splat2
        $_newSessions | Save-APSession -Path $_testDataPath

        It 'should get session by id' {
            (Get-APSession -Id $id -Path $_testDataPath).Id | Should be $id
        }
        It 'should get session by session name' {
            (Get-APSession -SessionName $sessionName -Path $_testDataPath).SessionName | Should be $sessionName
        }
        It 'should accept pipeline input' {
            $_getsession = Get-APSession -SessionName $sessionName -Path $_testDataPath
            ($_getsession | Get-APSession -Path $_testDataPath).SessionName | Should be $sessionName
        }
        It 'should return a secure personal access token' {
            $_getsession = Get-APSession -SessionName $sessionName -Path $_testDataPath
            $_getsession[0].PersonalAccessToken.GetType().Name | Should be SecureString
        }
    }
}
