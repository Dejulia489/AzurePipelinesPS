function Set-APTaskResult
{
    <#
    .SYNOPSIS

    Finish timeline record for current task, set task result and current operation.

    .DESCRIPTION

    Finish timeline record for current task, set task result and current operation.

    .PARAMETER Message

    The log message.

    .PARAMETER Result

    The result of the task, defaults to Succeeded.

    .INPUTS

    None, does not support the pipline.

    .OUTPUTS

    Task result.

    .EXAMPLE

    Set-TaskResult -Message 'Done' -Result 'Succeeded'

    #>
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]
        $Message,

        [Parameter()]
        [ValidateSet('Succeeded', 'SucceededWithIssues', 'Failed', 'Canceled', 'Skipped')]
        [string]
        $Result = 'Succeeded'
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
            Write-Host "##vso[task.complete result=$Result;]$Message"
        }
        else
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]: Result: [$Result], Message: [$Message]"
        }
    }
    end
    {

    }
}