#Requires -Version 7.0

<#
.SYNOPSIS
    Copilot Analysis Module - Generate comprehensive reports without external APIs

.DESCRIPTION
    Analyzes copilot structure and generates detailed reports based on
    data parsing and pattern recognition. No external API calls required.
#>

# ═══════════════════════════════════════════════════════════════
#  HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════

function Get-SystemTopics {
    <#
    .SYNOPSIS
        Returns list of standard system topics
    #>
    return @(
        "Greeting", "Fallback", "Escalate", "Sign in",
        "Conversation Start", "Multiple topics matched",
        "Thank you", "Goodbye", "On Error", "Confirmed Success",
        "Confirmed Failure", "Lesson", "Reset Conversation",
        "Start over", "End of Conversation", "Session Timeout",
        "Redirect to voice", "Conversation Repair", "Hand off to Dynamics 365"
    )
}

function Get-LanguageName {
    <#
    .SYNOPSIS
        Converts language code to friendly name
    #>
    param([int]$LanguageCode)

    $languageMap = @{
        1033 = "English"
        1036 = "French"
        1031 = "German"
        1034 = "Spanish"
        1040 = "Italian"
        1041 = "Japanese"
        1042 = "Korean"
        2052 = "Chinese (Simplified)"
        1028 = "Chinese (Traditional)"
        1046 = "Portuguese (Brazil)"
        2070 = "Portuguese (Portugal)"
        1043 = "Dutch"
        1049 = "Russian"
        1053 = "Swedish"
        1044 = "Norwegian"
        1035 = "Finnish"
        1030 = "Danish"
        1045 = "Polish"
        1029 = "Czech"
        1038 = "Hungarian"
        1032 = "Greek"
        1055 = "Turkish"
        1037 = "Hebrew"
        1025 = "Arabic"
        1081 = "Hindi"
        1054 = "Thai"
    }

    if ($languageMap.ContainsKey($LanguageCode)) {
        return $languageMap[$LanguageCode]
    }
    return "Language $LanguageCode"
}

function Get-ComplexityScore {
    <#
    .SYNOPSIS
        Calculates complexity score based on copilot structure
    #>
    param(
        [int]$TopicCount,
        [int]$CustomTopicCount,
        [int]$SkillCount,
        [int]$KnowledgeSourceCount,
        [long]$SizeBytes
    )

    # Topic complexity (0-10)
    $topicScore = [Math]::Min(10, ($TopicCount / 5))

    # Custom logic complexity (0-10)
    $customScore = [Math]::Min(10, ($CustomTopicCount / 3))

    # Integration complexity (0-10)
    $integrationScore = [Math]::Min(10, ($SkillCount * 2))

    # Knowledge complexity (0-10)
    $knowledgeScore = [Math]::Min(10, ($KnowledgeSourceCount * 1.5))

    # Size complexity (0-10) - 5MB = score of 5
    $sizeScore = [Math]::Min(10, ($SizeBytes / 1MB))

    # Weighted average
    $overall = ($topicScore * 0.3) + ($customScore * 0.25) +
               ($integrationScore * 0.2) + ($knowledgeScore * 0.15) +
               ($sizeScore * 0.1)

    return @{
        Overall = [Math]::Round($overall, 1)
        Topics = [Math]::Round($topicScore, 1)
        CustomLogic = [Math]::Round($customScore, 1)
        Integrations = [Math]::Round($integrationScore, 1)
        Knowledge = [Math]::Round($knowledgeScore, 1)
        Size = [Math]::Round($sizeScore, 1)
    }
}

function Get-ComplexityLevel {
    param([double]$Score)

    if ($Score -lt 3) { return "Low" }
    elseif ($Score -lt 6) { return "Medium" }
    elseif ($Score -lt 8) { return "Medium-High" }
    else { return "High" }
}

function Get-MigrationEstimate {
    param(
        [int]$ComponentCount,
        [double]$ComplexityScore
    )

    # Base time: 2 minutes
    # Add 5 seconds per component
    # Add time based on complexity
    $baseMinutes = 2
    $componentMinutes = ($ComponentCount * 5) / 60
    $complexityMinutes = ($ComplexityScore / 10) * 2

    $totalMinutes = $baseMinutes + $componentMinutes + $complexityMinutes

    return @{
        Minutes = [Math]::Round($totalMinutes, 1)
        Range = "$([Math]::Floor($totalMinutes))-$([Math]::Ceiling($totalMinutes + 1))"
    }
}

function Get-QualityAssessment {
    param(
        [PSCustomObject]$Analysis
    )

    $goodPractices = @()
    $improvements = @()
    $issues = @()

    # Check for good practices
    if ($Analysis.Topics.Custom.Count -gt 0) {
        $goodPractices += "Has custom topics (not just defaults)"
    }
    if ($Analysis.Topics.System -contains "On Error") {
        $goodPractices += "Has error handling topic"
    }
    if ($Analysis.Topics.System -contains "Escalate") {
        $goodPractices += "Has escalation path configured"
    }
    if ($Analysis.Skills.Count -gt 0) {
        $goodPractices += "Integrates with external systems"
    }
    if ($Analysis.KnowledgeSources.Count -gt 0) {
        $goodPractices += "Uses knowledge sources for answers"
    }
    if ($Analysis.Topics.Custom.Count -ge 3 -and $Analysis.Topics.Custom.Count -le 15) {
        $goodPractices += "Good topic organization (not too few, not too many)"
    }

    # Check for improvements
    if ($Analysis.Topics.Custom.Count -eq 0) {
        $improvements += "Add custom topics for specific use cases"
    }
    if ($Analysis.Topics.Custom.Count -eq 1 -and $Analysis.Topics.Custom[0].Name -eq "General") {
        $improvements += "Split 'General' topic into specific domains"
    }
    if ($Analysis.Skills.Count -eq 0) {
        $improvements += "Consider adding integrations for enhanced functionality"
    }
    if ($Analysis.KnowledgeSources.Count -eq 0) {
        $improvements += "Add knowledge sources for better answers"
    }
    if ($Analysis.Topics.Custom.Count -gt 20) {
        $improvements += "Consider consolidating topics for easier maintenance"
    }

    # Check for issues
    $duplicateNames = $Analysis.Topics.All | Group-Object Name | Where-Object Count -gt 1
    if ($duplicateNames) {
        $issues += "Duplicate topic names found: $($duplicateNames.Name -join ', ')"
    }

    # Calculate quality score
    $score = 5.0  # Base score
    $score += ($goodPractices.Count * 0.5)
    $score -= ($improvements.Count * 0.3)
    $score -= ($issues.Count * 1.0)
    $score = [Math]::Max(1, [Math]::Min(10, $score))

    return @{
        Score = [Math]::Round($score, 1)
        GoodPractices = $goodPractices
        Improvements = $improvements
        Issues = $issues
    }
}

# ═══════════════════════════════════════════════════════════════
#  MAIN ANALYSIS FUNCTION
# ═══════════════════════════════════════════════════════════════

function Get-CopilotAnalysis {
    <#
    .SYNOPSIS
        Analyzes copilot structure and generates comprehensive report

    .PARAMETER CopilotData
        The copilot data object (from Export-Copilot or JSON file)

    .PARAMETER IncludeDetails
        Include detailed topic and component listings

    .EXAMPLE
        $data = Get-Content "copilot-export.json" | ConvertFrom-Json
        $analysis = Get-CopilotAnalysis -CopilotData $data -IncludeDetails
    #>

    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$CopilotData,

        [switch]$IncludeDetails
    )

    Write-Verbose "Analyzing copilot structure..."

    # Extract bot metadata (handle both lowercase and uppercase property names)
    $bot = if ($CopilotData.Bot) { $CopilotData.Bot } else { $CopilotData.bot }

    # Extract components (handle both formats)
    if ($CopilotData.Components) {
        # Export format: Components object with Topics, Triggers, Skills arrays
        $componentsObj = $CopilotData.Components
        $components = @()
        if ($componentsObj.Topics) { $components += $componentsObj.Topics }
        if ($componentsObj.Triggers) { $components += $componentsObj.Triggers }
        if ($componentsObj.Skills) { $components += $componentsObj.Skills }
    } elseif ($CopilotData.components) {
        # Direct array format
        $components = $CopilotData.components
    } else {
        $components = @()
    }

    # Categorize components
    # Component types: 0=Topic, 1=Trigger, 2=Skill, 3=Variable, 4=Flow, etc.
    $systemTopicNames = Get-SystemTopics
    $topics = @($components | Where-Object { $_.componenttype -eq 0 })  # Topics
    $customTopics = @($topics | Where-Object { $_.name -notin $systemTopicNames })
    $systemTopics = @($topics | Where-Object { $_.name -in $systemTopicNames })

    $triggers = @($components | Where-Object { $_.componenttype -eq 1 })  # Triggers
    $skills = @($components | Where-Object { $_.componenttype -eq 2 })  # Skills/Actions
    $variables = @($components | Where-Object { $_.componenttype -eq 3 })  # Variables

    # Try to identify knowledge sources (may be in different structure)
    $knowledgeSources = @()
    if ($CopilotData.Components -and $CopilotData.Components.KnowledgeSources) {
        # From export format
        $knowledgeSources = @($CopilotData.Components.KnowledgeSources)
    } elseif ($bot.PSObject.Properties['mspva_knowledgesources']) {
        # From bot object
        $knowledgeSources = @($bot.mspva_knowledgesources)
    }

    # Calculate size
    $sizeBytes = if ($CopilotData.PSObject.Properties['_exportSize']) {
        $CopilotData._exportSize
    } else {
        ($CopilotData | ConvertTo-Json -Depth 10 -Compress).Length
    }

    # Build analysis object
    $analysis = [PSCustomObject]@{
        Bot = @{
            Name = $bot.name
            SchemaName = $bot.schemaname
            Language = Get-LanguageName -LanguageCode $bot.languagecode
            LanguageCode = $bot.languagecode
            Created = $bot.createdon
            Modified = $bot.modifiedon
            State = if ($bot.statecode -eq 0) { "Active" } else { "Inactive" }
            Owner = $bot._ownerid_value
            BotId = $bot.botid
        }

        Topics = @{
            Total = $topics.Count
            Custom = @($customTopics | Select-Object @{N='Name';E={$_.name}}, @{N='Description';E={$_.description}}, @{N='Id';E={$_.botcomponentid}})
            System = @($systemTopics | Select-Object @{N='Name';E={$_.name}}, @{N='Id';E={$_.botcomponentid}})
            All = @($topics | Select-Object @{N='Name';E={$_.name}}, @{N='Description';E={$_.description}}, @{N='Id';E={$_.botcomponentid}})
        }

        Skills = @($skills | Select-Object @{N='Name';E={$_.name}}, @{N='Description';E={$_.description}}, @{N='Id';E={$_.botcomponentid}})

        Triggers = @($triggers | Select-Object @{N='Name';E={$_.name}}, @{N='Description';E={$_.description}})

        Variables = @($variables | Select-Object @{N='Name';E={$_.name}}, @{N='Description';E={$_.description}})

        KnowledgeSources = $knowledgeSources

        Components = @{
            Total = $components.Count
            Topics = $topics.Count
            Skills = $skills.Count
            Triggers = $triggers.Count
            Variables = $variables.Count
        }

        Size = @{
            Bytes = $sizeBytes
            KB = [Math]::Round($sizeBytes / 1KB, 2)
            MB = [Math]::Round($sizeBytes / 1MB, 2)
        }
    }

    # Add complexity analysis
    $complexity = Get-ComplexityScore `
        -TopicCount $topics.Count `
        -CustomTopicCount $customTopics.Count `
        -SkillCount $skills.Count `
        -KnowledgeSourceCount $knowledgeSources.Count `
        -SizeBytes $sizeBytes

    $analysis | Add-Member -MemberType NoteProperty -Name "Complexity" -Value ([PSCustomObject]@{
        Overall = $complexity.Overall
        Level = Get-ComplexityLevel -Score $complexity.Overall
        Breakdown = [PSCustomObject]@{
            Topics = $complexity.Topics
            CustomLogic = $complexity.CustomLogic
            Integrations = $complexity.Integrations
            Knowledge = $complexity.Knowledge
            Size = $complexity.Size
        }
    })

    # Add migration estimate
    $estimate = Get-MigrationEstimate -ComponentCount $components.Count -ComplexityScore $complexity.Overall
    $analysis | Add-Member -MemberType NoteProperty -Name "Migration" -Value ([PSCustomObject]@{
        EstimatedMinutes = $estimate.Minutes
        EstimatedRange = $estimate.Range
        Difficulty = Get-ComplexityLevel -Score $complexity.Overall
        ComponentCount = $components.Count
    })

    # Add quality assessment
    $quality = Get-QualityAssessment -Analysis $analysis
    $analysis | Add-Member -MemberType NoteProperty -Name "Quality" -Value ([PSCustomObject]@{
        Score = $quality.Score
        Level = if ($quality.Score -ge 8) { "Excellent" } elseif ($quality.Score -ge 6) { "Good" } elseif ($quality.Score -ge 4) { "Fair" } else { "Needs Improvement" }
        GoodPractices = $quality.GoodPractices
        Improvements = $quality.Improvements
        Issues = $quality.Issues
    })

    # Generate summary description
    $purpose = "This copilot"
    if ($customTopics.Count -gt 0) {
        $topicNames = ($customTopics | Select-Object -First 3).name -join ", "
        $purpose += " handles topics including $topicNames"
        if ($customTopics.Count -gt 3) {
            $purpose += " and $($customTopics.Count - 3) more"
        }
    } else {
        $purpose += " uses standard system topics"
    }

    if ($skills.Count -gt 0) {
        $purpose += ". It integrates with $($skills.Count) external system(s)"
    }

    if ($knowledgeSources.Count -gt 0) {
        $purpose += " and uses $($knowledgeSources.Count) knowledge source(s)"
    }

    $purpose += "."

    $analysis | Add-Member -MemberType NoteProperty -Name "Summary" -Value $purpose

    return $analysis
}

# ═══════════════════════════════════════════════════════════════
#  REPORT GENERATION
# ═══════════════════════════════════════════════════════════════

function Show-CopilotAnalysisReport {
    <#
    .SYNOPSIS
        Displays formatted analysis report in console
    #>
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Analysis,

        [switch]$Detailed
    )

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              COPILOT ANALYSIS REPORT                             ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    # Bot Information
    Write-Host "🤖 " -NoNewline -ForegroundColor Cyan
    Write-Host $Analysis.Bot.Name -ForegroundColor White
    Write-Host "🆔 Bot ID: " -NoNewline -ForegroundColor Gray
    Write-Host $Analysis.Bot.BotId -ForegroundColor White
    Write-Host "📅 Created: " -NoNewline -ForegroundColor Gray
    Write-Host "$($Analysis.Bot.Created) | Modified: $($Analysis.Bot.Modified)" -ForegroundColor White
    Write-Host "🌐 Language: " -NoNewline -ForegroundColor Gray
    Write-Host "$($Analysis.Bot.Language) ($($Analysis.Bot.LanguageCode))" -ForegroundColor White
    Write-Host "📊 State: " -NoNewline -ForegroundColor Gray
    Write-Host $Analysis.Bot.State -ForegroundColor $(if ($Analysis.Bot.State -eq "Active") { "Green" } else { "Yellow" })
    Write-Host ""

    # Summary
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📋 SUMMARY" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  $($Analysis.Summary)" -ForegroundColor White
    Write-Host ""

    # Structure
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🏗️  STRUCTURE" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Topics: " -NoNewline -ForegroundColor Gray
    Write-Host "$($Analysis.Topics.Total) total" -ForegroundColor White
    Write-Host "    • Custom: " -NoNewline -ForegroundColor Gray
    Write-Host "$($Analysis.Topics.Custom.Count)" -ForegroundColor Cyan
    Write-Host "    • System: " -NoNewline -ForegroundColor Gray
    Write-Host "$($Analysis.Topics.System.Count)" -ForegroundColor Gray
    Write-Host ""

    if ($Analysis.Topics.Custom.Count -gt 0) {
        Write-Host "  Custom Topics:" -ForegroundColor Gray
        foreach ($topic in $Analysis.Topics.Custom | Select-Object -First $(if ($Detailed) { 999 } else { 5 })) {
            Write-Host "    ✓ " -NoNewline -ForegroundColor Green
            Write-Host $topic.Name -ForegroundColor White
            if ($topic.Description) {
                Write-Host "      " -NoNewline
                Write-Host $topic.Description -ForegroundColor Gray
            }
        }
        if ($Analysis.Topics.Custom.Count -gt 5 -and -not $Detailed) {
            Write-Host "    ... and $($Analysis.Topics.Custom.Count - 5) more" -ForegroundColor Gray
        }
        Write-Host ""
    }

    if ($Analysis.Skills.Count -gt 0) {
        Write-Host "  Skills & Integrations: " -NoNewline -ForegroundColor Gray
        Write-Host "$($Analysis.Skills.Count)" -ForegroundColor Cyan
        foreach ($skill in $Analysis.Skills) {
            Write-Host "    • " -NoNewline -ForegroundColor Cyan
            Write-Host $skill.Name -ForegroundColor White
            if ($skill.Description) {
                Write-Host "      " -NoNewline
                Write-Host $skill.Description -ForegroundColor Gray
            }
        }
        Write-Host ""
    }

    if ($Analysis.KnowledgeSources.Count -gt 0) {
        Write-Host "  Knowledge Sources: " -NoNewline -ForegroundColor Gray
        Write-Host "$($Analysis.KnowledgeSources.Count)" -ForegroundColor Cyan
        foreach ($source in $Analysis.KnowledgeSources) {
            Write-Host "    • " -NoNewline -ForegroundColor Magenta
            Write-Host $source.name -ForegroundColor White
        }
        Write-Host ""
    }

    Write-Host "  Total Components: " -NoNewline -ForegroundColor Gray
    Write-Host "$($Analysis.Components.Total)" -ForegroundColor White
    Write-Host "  Size: " -NoNewline -ForegroundColor Gray
    Write-Host "$($Analysis.Size.MB) MB ($($Analysis.Size.KB) KB)" -ForegroundColor White
    Write-Host ""

    # Complexity
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📊 COMPLEXITY ANALYSIS" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Overall Score: " -NoNewline -ForegroundColor Gray
    Write-Host "$($Analysis.Complexity.Overall)/10 " -NoNewline -ForegroundColor $(
        if ($Analysis.Complexity.Overall -lt 4) { "Green" }
        elseif ($Analysis.Complexity.Overall -lt 7) { "Yellow" }
        else { "Red" }
    )
    Write-Host "($($Analysis.Complexity.Level))" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Breakdown:" -ForegroundColor Gray
    Write-Host "    Topics:       $($Analysis.Complexity.Breakdown.Topics)/10" -ForegroundColor White
    Write-Host "    Custom Logic: $($Analysis.Complexity.Breakdown.CustomLogic)/10" -ForegroundColor White
    Write-Host "    Integrations: $($Analysis.Complexity.Breakdown.Integrations)/10" -ForegroundColor White
    Write-Host "    Knowledge:    $($Analysis.Complexity.Breakdown.Knowledge)/10" -ForegroundColor White
    Write-Host "    Size:         $($Analysis.Complexity.Breakdown.Size)/10" -ForegroundColor White
    Write-Host ""

    # Quality
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""
    Write-Host "⭐ QUALITY ASSESSMENT" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Quality Score: " -NoNewline -ForegroundColor Gray
    Write-Host "$($Analysis.Quality.Score)/10 " -NoNewline -ForegroundColor $(
        if ($Analysis.Quality.Score -ge 8) { "Green" }
        elseif ($Analysis.Quality.Score -ge 6) { "Yellow" }
        else { "Red" }
    )
    Write-Host "($($Analysis.Quality.Level))" -ForegroundColor Gray
    Write-Host ""

    if ($Analysis.Quality.GoodPractices.Count -gt 0) {
        Write-Host "  ✅ Good Practices ($($Analysis.Quality.GoodPractices.Count)):" -ForegroundColor Green
        foreach ($practice in $Analysis.Quality.GoodPractices) {
            Write-Host "     ✓ $practice" -ForegroundColor Green
        }
        Write-Host ""
    }

    if ($Analysis.Quality.Improvements.Count -gt 0) {
        Write-Host "  ⚠️  Suggested Improvements ($($Analysis.Quality.Improvements.Count)):" -ForegroundColor Yellow
        foreach ($improvement in $Analysis.Quality.Improvements) {
            Write-Host "     ! $improvement" -ForegroundColor Yellow
        }
        Write-Host ""
    }

    if ($Analysis.Quality.Issues.Count -gt 0) {
        Write-Host "  ❌ Issues Found ($($Analysis.Quality.Issues.Count)):" -ForegroundColor Red
        foreach ($issue in $Analysis.Quality.Issues) {
            Write-Host "     ✗ $issue" -ForegroundColor Red
        }
        Write-Host ""
    }

    # Migration
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🚀 MIGRATION READINESS" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Estimated Time: " -NoNewline -ForegroundColor Gray
    Write-Host "$($Analysis.Migration.EstimatedRange) minutes" -ForegroundColor White
    Write-Host "  Difficulty: " -NoNewline -ForegroundColor Gray
    Write-Host $Analysis.Migration.Difficulty -ForegroundColor $(
        if ($Analysis.Migration.Difficulty -eq "Low") { "Green" }
        elseif ($Analysis.Migration.Difficulty -match "Medium") { "Yellow" }
        else { "Red" }
    )
    Write-Host "  Components to Migrate: " -NoNewline -ForegroundColor Gray
    Write-Host "$($Analysis.Migration.ComponentCount)" -ForegroundColor White
    Write-Host ""

    Write-Host "  Readiness: " -NoNewline -ForegroundColor Gray
    if ($Analysis.Quality.Issues.Count -eq 0) {
        Write-Host "✅ Ready for migration" -ForegroundColor Green
    } elseif ($Analysis.Quality.Issues.Count -le 2) {
        Write-Host "⚠️  Can migrate, but review issues first" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Fix issues before migrating" -ForegroundColor Red
    }
    Write-Host ""

    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Report Generated: " -NoNewline -ForegroundColor Gray
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
    Write-Host "Analysis Engine: " -NoNewline -ForegroundColor Gray
    Write-Host "Navigator v1.0" -ForegroundColor White
    Write-Host ""
}

function Export-CopilotAnalysisReport {
    <#
    .SYNOPSIS
        Exports analysis report to file
    #>
    param(
        [Parameter(Mandatory)]
        [PSCustomObject]$Analysis,

        [Parameter(Mandatory)]
        [string]$OutputPath,

        [ValidateSet("Markdown", "JSON", "Text")]
        [string]$Format = "Markdown"
    )

    $filename = "$($Analysis.Bot.Name -replace '[^a-zA-Z0-9]', '_')-Analysis-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

    switch ($Format) {
        "Markdown" {
            $content = @"
# $($Analysis.Bot.Name) - Copilot Analysis Report

**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Bot ID:** $($Analysis.Bot.BotId)
**State:** $($Analysis.Bot.State)

---

## 📋 Summary

$($Analysis.Summary)

---

## 🏗️ Structure

### Topics
- **Total:** $($Analysis.Topics.Total)
- **Custom:** $($Analysis.Topics.Custom.Count)
- **System:** $($Analysis.Topics.System.Count)

#### Custom Topics

$($Analysis.Topics.Custom | ForEach-Object { "- **$($_.Name)**" + $(if ($_.Description) { ": $($_.Description)" } else { "" }) } | Out-String)

### Skills & Integrations
- **Count:** $($Analysis.Skills.Count)

$($Analysis.Skills | ForEach-Object { "- **$($_.Name)**" + $(if ($_.Description) { ": $($_.Description)" } else { "" }) } | Out-String)

### Knowledge Sources
- **Count:** $($Analysis.KnowledgeSources.Count)

$($Analysis.KnowledgeSources | ForEach-Object { "- $($_.name)" } | Out-String)

### Size
- **Total:** $($Analysis.Size.MB) MB
- **Components:** $($Analysis.Components.Total)

---

## 📊 Complexity Analysis

**Overall Score:** $($Analysis.Complexity.Overall)/10 ($($Analysis.Complexity.Level))

### Breakdown
- Topics: $($Analysis.Complexity.Breakdown.Topics)/10
- Custom Logic: $($Analysis.Complexity.Breakdown.CustomLogic)/10
- Integrations: $($Analysis.Complexity.Breakdown.Integrations)/10
- Knowledge: $($Analysis.Complexity.Breakdown.Knowledge)/10
- Size: $($Analysis.Complexity.Breakdown.Size)/10

---

## ⭐ Quality Assessment

**Quality Score:** $($Analysis.Quality.Score)/10 ($($Analysis.Quality.Level))

### ✅ Good Practices
$($Analysis.Quality.GoodPractices | ForEach-Object { "- $_" } | Out-String)

### ⚠️ Suggested Improvements
$($Analysis.Quality.Improvements | ForEach-Object { "- $_" } | Out-String)

### ❌ Issues Found
$($Analysis.Quality.Issues | ForEach-Object { "- $_" } | Out-String)

---

## 🚀 Migration Readiness

- **Estimated Time:** $($Analysis.Migration.EstimatedRange) minutes
- **Difficulty:** $($Analysis.Migration.Difficulty)
- **Components:** $($Analysis.Migration.ComponentCount)
- **Status:** $(if ($Analysis.Quality.Issues.Count -eq 0) { "✅ Ready" } else { "⚠️ Review needed" })

---

*Report generated by Navigator Analysis Engine v1.0*
"@
            $filepath = Join-Path $OutputPath "$filename.md"
            $content | Out-File -FilePath $filepath -Encoding UTF8
        }

        "JSON" {
            $filepath = Join-Path $OutputPath "$filename.json"
            $Analysis | ConvertTo-Json -Depth 10 | Out-File -FilePath $filepath -Encoding UTF8
        }

        "Text" {
            $filepath = Join-Path $OutputPath "$filename.txt"
            # Capture console output
            $content = Show-CopilotAnalysisReport -Analysis $Analysis -Detailed 6>&1 | Out-String
            $content | Out-File -FilePath $filepath -Encoding UTF8
        }
    }

    return $filepath
}

# Export module members
Export-ModuleMember -Function @(
    'Get-CopilotAnalysis',
    'Show-CopilotAnalysisReport',
    'Export-CopilotAnalysisReport'
)
