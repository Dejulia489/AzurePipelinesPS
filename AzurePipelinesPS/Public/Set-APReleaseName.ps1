function Set-APReleaseName
{
    <#
    .SYNOPSIS

    Pipeline invocation command used to update the release name for the current release.

    .DESCRIPTION

    Pipeline invocation command used to update the release name for the current release
    Pipeline invocation commands make changes during pipeline execution. If the command is excuted in a console window the command will output logging messages. 

    .PARAMETER ReleaseName

    The new release name.

    .INPUTS

    None, does not support the pipline.

    .OUTPUTS

    VSO release name.

    .EXAMPLE

    Set-APReleaseName -ReleaseName 'My New Release Name'

    #>
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $ReleaseName
    )
    begin
    {
        If ($env:Build_BuildId -or $env:Release_DefinitionId)
        {
            $pipelineInvocation = $true
        }
    }
    process
    {
        If ($pipelineInvocation)
        {
            Write-Host "##vso[build.updatereleasename]$ReleaseName"
        }
        else
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]: Updated release name to: [$ReleaseName]"
        }
    }
    end
    {

    }
}