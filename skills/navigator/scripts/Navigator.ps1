#Requires -Version 7.0

<#
.SYNOPSIS
    Navigator - Copilot Deployment Skill

.DESCRIPTION
    Deploy Copilot Studio bots across any Power Platform environment with two modes:

    SmartTest Mode (default):
    - Fast deployment to any environment (30-60 seconds)
    - No solution packaging
    - Update in place
    - Perfect for testing and iteration

    DV Mode (DV Solution Migration):
    - Production deployment (4-8 minutes)
    - Dataverse solution packaging with audit trail
    - Managed components
    - Production-grade

.PARAMETER Mode
    SmartTest or DV (default: SmartTest)

.PARAMETER BotName
    Name of copilot to deploy

.PARAMETER Source
    Source environment

.PARAMETER Target
    Target environment

.PARAMETER OpenTestChat
    Open test chat in browser after deployment (SmartTest mode only)

.EXAMPLE
    # SmartTest deploy (default) - Interactive
    .\Navigator.ps1

.EXAMPLE
    # SmartTest deploy with parameters
    .\Navigator.ps1 -Mode SmartTest -BotName "Sales Assistant" -Target "UAT"

.EXAMPLE
    # SmartTest deploy shorthand
    .\Navigator.ps1 smarttest

.EXAMPLE
    # DV Solution Migration to production
    .\Navigator.ps1 -Mode DV -Target "Production"

.EXAMPLE
    # DV Solution Migration shorthand
    .\Navigator.ps1 dv

.NOTES
    Author: Copilot Zapper Team
    Version: 2.1.0
    Requires: Azure CLI, PowerShell 7.0+
#>

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$Command,  # Can be: "smarttest", "dv", "test", "deploy", "migrate", "production", or bot name

    [ValidateSet('SmartTest', 'DV')]
    [string]$Mode = 'SmartTest',  # Default to SmartTest

    [string]$BotName,
    [string]$Source = 'Development',
    [string]$Target,

    [switch]$OpenTestChat,
    [switch]$NoConfirm
)

# Banner
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🧭 NAVIGATOR - Copilot Deployment Skill" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Import modules
try {
    Import-Module (Join-Path $PSScriptRoot "Copilot-Core.psm1") -Force
    Import-Module (Join-Path $PSScriptRoot "Copilot-QuickDeploy.psm1") -Force
}
catch {
    Write-Error "Failed to import required modules: $_"
    Write-Host ""
    Write-Host "Please ensure the following modules exist:" -ForegroundColor Yellow
    Write-Host "  - Copilot-Core.psm1" -ForegroundColor Gray
    Write-Host "  - Copilot-QuickDeploy.psm1" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Parse command if provided
if ($Command) {
    switch -Regex ($Command) {
        '^(smarttest|test|deploy)$' {
            $Mode = 'SmartTest'
            Write-Verbose "Mode set to SmartTest via command: $Command"
        }
        '^(dv|migrate|production)$' {
            $Mode = 'DV'
            Write-Verbose "Mode set to DV via command: $Command"
        }
        default {
            # Assume it's a bot name
            if (-not $BotName) {
                $BotName = $Command
                Write-Verbose "Bot name set via command: $BotName"
            }
        }
    }
}

# Production always uses DV Solution Migration
if ($Target -eq 'Production' -and $Mode -eq 'SmartTest') {
    Write-Host "🔒 Target is Production - automatically switching to DV Solution Migration for safety" -ForegroundColor Yellow
    Write-Host ""
    $Mode = 'DV'
}

# Interactive selection if parameters not provided
if ($Source -eq 'Development') {
    try {
        Write-Host "Select source environment:" -ForegroundColor Yellow
        $Source = Select-Environment
    }
    catch {
        Write-Error "Failed to select source environment: $_"
        exit 1
    }
}

if (-not $BotName) {
    try {
        $BotName = Select-Copilot -Environment $Source
    }
    catch {
        Write-Error "Failed to select copilot: $_"
        exit 1
    }
}

if (-not $Target) {
    try {
        $Target = Select-Environment -Exclude $Source
    }
    catch {
        Write-Error "Failed to select target environment: $_"
        exit 1
    }
}

# Show deployment configuration
Write-Host "📋 Deployment Configuration:" -ForegroundColor Yellow
Write-Host "  Copilot:  $BotName" -ForegroundColor White
Write-Host "  From:     $Source" -ForegroundColor White
Write-Host "  To:       $Target" -ForegroundColor White
Write-Host "  Mode:     " -NoNewline -ForegroundColor White
if ($Mode -eq 'SmartTest') {
    Write-Host "Smart Test " -NoNewline -ForegroundColor Green
    Write-Host "(fast, no solution, ~30-60s)" -ForegroundColor Gray
} else {
    Write-Host "DV Solution Migration " -NoNewline -ForegroundColor Magenta
    Write-Host "(with DV solution, ~4-8min)" -ForegroundColor Gray
}
Write-Host ""

# Confirmation
if (-not $NoConfirm) {
    $response = Read-Host "Continue? [Y/n]"
    if ($response -and $response -notmatch '^[Yy]') {
        Write-Host ""
        Write-Host "❌ Deployment cancelled" -ForegroundColor Yellow
        Write-Host ""
        exit 0
    }
}

Write-Host ""

# Execute based on mode
try {
    switch ($Mode) {
        'SmartTest' {
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
            Write-Host "⚡ SMART TEST MODE" -ForegroundColor Green
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green

            $result = Invoke-QuickDeploy `
                -BotName $BotName `
                -SourceEnvironment $Source `
                -TargetEnvironment $Target `
                -OpenTestChat:$OpenTestChat

            Write-Host ""
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
            Write-Host "✅ SMART TEST COMPLETE" -ForegroundColor Green
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
            Write-Host ""
            Write-Host "  Time:   $($result.Duration)" -ForegroundColor White
            Write-Host "  Action: $($result.Action)" -ForegroundColor White
            Write-Host "  Bot ID: $($result.BotId)" -ForegroundColor Gray
            Write-Host ""
            Write-Host "🔗 Test URL:" -ForegroundColor Cyan
            Write-Host "  $($result.TestUrl)" -ForegroundColor White
            Write-Host ""
            Write-Host "💡 Tip: Deployed directly (no solution). To delete, just remove the bot from $Target." -ForegroundColor Gray
            Write-Host ""
        }

        'DV' {
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
            Write-Host "📦 DV SOLUTION MIGRATION MODE" -ForegroundColor Magenta
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
            Write-Host ""

            $originalScript = Join-Path $PSScriptRoot "Invoke-Navigator.ps1"

            if (Test-Path $originalScript) {
                Write-Host "Launching DV Solution Migration..." -ForegroundColor Cyan
                Write-Host ""
                & $originalScript
            }
            else {
                Write-Error "DV Solution Migration script not found at: $originalScript"
                Write-Host ""
                Write-Host "Please ensure Invoke-Navigator.ps1 exists for DV Solution Migration mode." -ForegroundColor Yellow
                Write-Host ""
                exit 1
            }
        }
    }
}
catch {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host "❌ DEPLOYMENT FAILED" -ForegroundColor Red
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host ""

    if ($_.Exception.StackTrace) {
        Write-Verbose "Stack trace: $($_.Exception.StackTrace)"
    }

    exit 1
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
