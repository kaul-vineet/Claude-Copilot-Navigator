#Requires -Version 7.0

<#
.SYNOPSIS
    LLM-powered intelligence for Copilot Studio migrations

.DESCRIPTION
    Provides AI-powered analysis, error diagnosis, and recommendations
    for Microsoft Copilot Studio bot migrations using Claude API

.NOTES
    Requires ANTHROPIC_API_KEY environment variable
#>

function Invoke-ClaudeAPI {
    <#
    .SYNOPSIS
        Call Claude API for AI reasoning (or use Claude Code's built-in Claude when running as skill)
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Prompt,

        [int]$MaxTokens = 2000,

        [string]$Model = "claude-sonnet-4-5-20250929",

        [object]$Data = $null,

        [switch]$SkillMode
    )

    # Check if running as Claude Code skill
    if ($env:CLAUDE_CODE_SKILL -eq "true" -or $SkillMode) {
        # Display analysis request for Claude Code's Claude
        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host "🤖 AI ANALYSIS REQUEST" -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Claude, please analyze:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host $Prompt -ForegroundColor White

        if ($Data) {
            Write-Host ""
            Write-Host "DATA:" -ForegroundColor Cyan
            Write-Host ($Data | ConvertTo-Json -Depth 5 -Compress) -ForegroundColor Gray
        }

        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "👆 Claude will provide analysis above this line." -ForegroundColor Yellow
        Write-Host ""

        # Don't pause - let Claude respond naturally in the conversation
        return "SKILL_MODE_ANALYSIS_REQUESTED"
    }

    # Standalone mode - try to use API
    $apiKey = $env:ANTHROPIC_API_KEY
    if (-not $apiKey) {
        return $null
    }

    try {
        $headers = @{
            "x-api-key" = $apiKey
            "anthropic-version" = "2023-06-01"
            "content-type" = "application/json"
        }

        $body = @{
            model = $Model
            max_tokens = $MaxTokens
            messages = @(
                @{
                    role = "user"
                    content = $Prompt
                }
            )
        } | ConvertTo-Json -Depth 10

        $response = Invoke-RestMethod `
            -Uri "https://api.anthropic.com/v1/messages" `
            -Method Post `
            -Headers $headers `
            -Body $body `
            -TimeoutSec 30

        return $response.content[0].text
    }
    catch {
        Write-Warning "Claude API call failed: $_"
        return $null
    }
}

function Get-MigrationReadinessWithLLM {
    <#
    .SYNOPSIS
        Analyze bot for migration readiness using AI
    #>
    param(
        [Parameter(Mandatory=$true)]
        [object]$BotAnalysis,

        [Parameter(Mandatory=$true)]
        [string]$TargetEnvironment
    )

    $prompt = @"
Analyze this Microsoft Copilot Studio bot for migration readiness:

BOT INFORMATION:
- Name: $($BotAnalysis.BotName)
- Language: $($BotAnalysis.Language)
- Complexity Score: $($BotAnalysis.ComplexityScore)/10

COMPONENT COUNTS:
- Topics: $($BotAnalysis.ComponentCounts.Topics) (Custom: $($BotAnalysis.ComponentCounts.CustomTopics))
- Skills: $($BotAnalysis.ComponentCounts.Skills)
- Triggers: $($BotAnalysis.ComponentCounts.Triggers)
- Knowledge Sources: $($BotAnalysis.ComponentCounts.KnowledgeSources)

TARGET ENVIRONMENT: $TargetEnvironment

Please provide a structured analysis in this format:

## MIGRATION READINESS ASSESSMENT

### Risk Level
[Low/Medium/High]

### Predicted Issues
1. [Issue 1 with explanation]
2. [Issue 2 with explanation]
...

### Pre-Migration Checklist
- [ ] Item 1
- [ ] Item 2
...

### Recommended Approach
[Template-only or Full migration with reasoning]

### Estimated Time
[Time estimate with breakdown]

### Post-Migration Validation
1. Step 1
2. Step 2
...
"@

    $analysis = Invoke-ClaudeAPI -Prompt $prompt -MaxTokens 2000
    return $analysis
}

function Analyze-ComponentFailureWithLLM {
    <#
    .SYNOPSIS
        Diagnose component import failure using AI (skill-aware)
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComponentName,

        [Parameter(Mandatory=$true)]
        [string]$ComponentType,

        [Parameter(Mandatory=$true)]
        [string]$ErrorMessage,

        [object]$ComponentData
    )

    $prompt = @"
A Microsoft Copilot Studio component failed during migration import:

COMPONENT: $ComponentType - $ComponentName
ERROR: $ErrorMessage

Please provide diagnostic analysis in this format:

## 🔍 ROOT CAUSE
[Simple explanation of why this failed]

## 🔧 FIX STEPS
1. [Specific action in target environment]
2. [Next action]
...

## 🔄 ALTERNATIVE APPROACH
[If direct fix isn't possible, suggest alternative]

## ⚠️ IMPACT IF SKIPPED
[Consequences of not fixing this component]

## 📊 PRIORITY
[Critical/High/Medium/Low]

Keep responses concise and actionable.
"@

    $analysis = Invoke-ClaudeAPI `
        -Prompt $prompt `
        -Data $ComponentData `
        -MaxTokens 1500

    return $analysis
}

function Get-PostMigrationReviewWithLLM {
    <#
    .SYNOPSIS
        Generate post-migration review and recommendations
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$BotId,

        [Parameter(Mandatory=$true)]
        [int]$TotalComponents,

        [Parameter(Mandatory=$true)]
        [int]$SuccessCount,

        [array]$FailedComponents = @()
    )

    $failedDetails = if ($FailedComponents.Count -gt 0) {
        $FailedComponents | ForEach-Object {
            "- $($_.Type): $($_.Name) - $($_.Error)"
        }
    } else {
        "None - all components imported successfully"
    }

    $prompt = @"
Review this completed Microsoft Copilot Studio migration:

MIGRATION RESULTS:
- Bot ID: $BotId
- Total Components: $TotalComponents
- Successfully Imported: $SuccessCount
- Failed: $($FailedComponents.Count)

FAILED COMPONENTS:
$($failedDetails -join "`n")

Provide structured review:

## MIGRATION QUALITY SCORE
[X/10] with brief justification

## CRITICAL ACTIONS REQUIRED
- [ ] Action 1
- [ ] Action 2

## RECOMMENDED NEXT STEPS
1. Step 1
2. Step 2
...

## TESTING CHECKLIST
- [ ] Test item 1
- [ ] Test item 2
...

## MONITORING RECOMMENDATIONS
[What to watch for post-deployment]

Be specific and actionable. Focus on the failed components if any.
"@

    $review = Invoke-ClaudeAPI -Prompt $prompt -MaxTokens 2000
    return $review
}

# Export functions
Export-ModuleMember -Function @(
    'Invoke-ClaudeAPI'
    'Get-MigrationReadinessWithLLM'
    'Analyze-ComponentFailureWithLLM'
    'Get-PostMigrationReviewWithLLM'
)
