function Add-APLogFile
{
    <#
    .SYNOPSIS

    Pipeline invocation command used to upload and attach a file to the pipeline timeline record.

    .DESCRIPTION

    Pipeline invocation command used to upload and attach a file to the pipeline timeline record.
    The file shall be available for download along with task logs.
    
    .PARAMETER Path

    The path to the markdown file to upload to the release summary.

    .INPUTS

    None, does not support the pipline.

    .OUTPUTS

    None, does not support output.

    .EXAMPLE

    Add-APLogFile -Path '.\myFile.txt'

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
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]: Uploading the file from [$Path] to the pipeline logs."
            If ($pipelineInvocation)
            {
                Write-Host "##vso[task.uploadfile]$Path"
            }
        }
        else
        {
            Write-Error "[$($MyInvocation.MyCommand.Name)]: Unable to locate file at [$Path]"
        }
    }
    end
    {

    }
}