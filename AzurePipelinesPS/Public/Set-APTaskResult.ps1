function Set-APTaskResult
{
    <#
    .SYNOPSIS

    Pipeline invocation command used to set the finish timeline record for current task, set task result and current operation.

    .DESCRIPTION

    Pipeline invocation command used to set the finish timeline record for current task, set task result and current operation.
    Pipeline invocation commands make changes during pipeline execution. If the command is excuted in a console window the command will output logging messages. 

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
        If ($env:Build_BuildId -or $env:Release_DefinitionId)
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