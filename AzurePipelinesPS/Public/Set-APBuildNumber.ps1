function Set-APBuildNumber
{
    <#
    .SYNOPSIS

    Pipeline invocation command used to update build number for current build.

    .DESCRIPTION

    Pipeline invocation command used to update build number for current build.
    Pipeline invocation commands make changes during pipeline execution. If the command is excuted in a console window the command will output logging messages. 

    .PARAMETER BuildNumber

    The new build number.

    .INPUTS

    None, does not support the pipline.

    .OUTPUTS

    VSO build number.

    .EXAMPLE

    Set-APBuildNumber -BuildNumber '1.0.0'

    #>
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $BuildNumber
    )
    begin
    {
        If ($env:Build_DefinitionId -or $env:Release_DefinitionId)
        {
            $pipelineInvocation = $true
        }
    }
    process
    {
        If ($pipelineInvocation)
        {
            Write-Host "##vso[build.updatebuildnumber]$BuildNumber"
        }
        else
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]: Updated build number to: [$BuildNumber]"
        }
    }
    end
    {

    }
}