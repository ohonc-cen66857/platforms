
@{
    IncludeRules = @(
        'PSUseConsistentWhitespace',
        'PSUseConsistentIndentation',
        'PSUseApprovedVerbs',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingWriteHost',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPlainTextForPassword'
    )
    ExcludeRules = @('PSUseShouldProcessForStateChangingFunctions')
    Rules = @{
        PSUseConsistentWhitespace = @{
            CheckInnerWhitespace = $true
            CheckOpenBrace       = $true
            CheckOpenParen       = $true
            CheckOperator        = $true
            CheckPipe            = $true
            CheckSeparator       = $true
            CheckVerboseMarker   = $true
        }
        PSUseConsistentIndentation = @{
            IndentationSize     = 2
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind                = 'space'
        }
        PSUseApprovedVerbs = @{ Enable = $true }
        PSAvoidUsingCmdletAliases = @{ Enable = $true }
    }
}
