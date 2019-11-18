function Update-APReleaseSummary
{
    <#
    .SYNOPSIS

    Pipeline invocation command used to upload and attach summary markdown to current timeline record.

    .DESCRIPTION

    Pipeline invocation command used to upload and attach summary markdown to current timeline record.
    This summary shall be added to the build/release summary and not available for download with logs.
    
    .PARAMETER Path

    The path to the markdown file to upload to the release summary.

    .PARAMETER Name

    The name of the expandable section in the release summary.

    .INPUTS

    None, does not support the pipline.

    .OUTPUTS

    None, does not support output.

    .EXAMPLE

    Update-APReleaseSummary -Path '.\mySummary.md'

    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter(Mandatory)]
        [string]
        $Name
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
        If (Test-Path $Path)
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]: Uploading the file from [$Path] to the release summary."
            If ($pipelineInvocation)
            {
                Write-Host "##vso[task.addattachment type=Distributedtask.Core.Summary;name=$Name;]$Path"
            }
        }
        Else
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate file at [$Path]"
        }
    }
    end
    {

    }
}