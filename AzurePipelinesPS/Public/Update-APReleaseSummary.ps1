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
        $Path
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
            If ($pipelineInvocation)
            {
                Write-Host "##vso[task.uploadsummary]$Path"
            }
            else
            {
                Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]: Uploaded the file from [$Path] to the release summary."
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