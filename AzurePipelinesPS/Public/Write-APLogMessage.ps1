function Write-APLogMessage
{
    <#
    .SYNOPSIS

    Writes a log message to a powershell channel or an Azure DevOps pipeline timeline record log.

    .DESCRIPTION

    Writes a log message to a powershell channel or an Azure DevOps pipeline timeline record log. 
    The function will determine if it has been invoked by a pipeline or not.

    .PARAMETER Message

    The log message.

    .PARAMETER Error

    Switch, the log should be an error.

    .PARAMETER Warning

    Switch, the log should be a warning.

    .INPUTS

    None, does not support the pipline

    .OUTPUTS

    Log, error or warning.

    .EXAMPLE

    Write-APLogMessage -Message 'This is an error message!' -Error

    .EXAMPLE

    Write-APLogMessage -Message 'This is an warning message!' -Warning

    #>
    [CmdletBinding(DefaultParameterSetName = 'ByError')]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Message,

        [Parameter(Mandatory,
            ParameterSetName = 'ByError')]
        [switch]
        $Error,

        [Parameter(Mandatory,
            ParameterSetName = 'ByWarning')]
        [switch]
        $Warning
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
        Switch ($PSCmdlet.ParameterSetName)
        {
            'ByError'
            {
                If ($pipelineInvocation)
                {
                    Write-Host "##vso[task.logissue type=error;]$Message"
                }
                else
                {
                    Write-Error -Message $Message
                }
            }
            'ByWarning'
            {
                If ($pipelineInvocation)
                {
                    Write-Host "##vso[task.logissue type=warning;]$Message"
                }
                else
                {
                    Write-Warning -Message $Message
                }
            }
        }
    }
    end
    {

    }
}