function Set-APVariable
{
    <#
    .SYNOPSIS

    Pipeline invocation command used to set a variable in the variable service of taskcontext.

    .DESCRIPTION

    Pipeline invocation command used to set a variable in the variable service of taskcontext.
    The first task can set a variable, and following tasks in the same phase are able to use the variable. 
    Pipeline invocation commands make changes during pipeline execution. If the command is excuted in a console window the command will output logging messages. 

    .PARAMETER Name

    The name of the variable to set.

    .PARAMETER Value

    The value of the variable.

    .PARAMETER IsSecret

    Sets the variable to a secret. 
    When issecret is set to true, the value of the variable will be saved as secret and masked out from log. 
    Secret variables are not passed into tasks as environment variables and must be passed as inputs.

    .PARAMETER IsOutput

    Sets the variable to an output variable.

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
        [Parameter(Mandatory)]
        [string]
        $Name, 

        [Parameter(Mandatory)]
        [string]
        $Value, 

        [Parameter()]
        [switch]
        $IsSecret,

        [Parameter()]
        [switch]
        $IsOutput
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
            Write-Host "##vso[task.setvariable variable=$Name;issecret=$($IsSecret.IsPresent);isOutput=$($IsOutput.IsPresent)]$Value"
        }
        else
        {
            If ($IsSecret.IsPresent)
            {
                Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]: Updated the variable [$Name] to the value of [*****]. IsOutput set to [$($IsOutput.IsPresent)]"
            }
            else
            {
                Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]: Updated the variable [$Name] to the value of [$Value]. IsOutput set to [$($IsOutput.IsPresent)]"
            }
        }
    }
    end
    {

    }
}