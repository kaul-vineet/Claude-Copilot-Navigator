#Requires -Version 7.0

<#
.SYNOPSIS
    Navigator v2.0 - Copilot Deployment Tool

.DESCRIPTION
    Deploy Copilot Studio bots across environments with two modes:

    Quick Mode (default):
    - Fast testing deployment (30-60 seconds)
    - No solution packaging
    - Update in place
    - Perfect for iteration

    Full Mode:
    - Production deployment (4-8 minutes)
    - Solution packaging with audit trail
    - Managed components
    - Production-grade

.PARAMETER Mode
    Quick or Full (default: Quick)

.PARAMETER BotName
    Name of copilot to deploy

.PARAMETER Source
    Source environment (default: Development)

.PARAMETER Target
    Target environment

.PARAMETER OpenTestChat
    Open test chat in browser after deployment (Quick mode only)

.EXAMPLE
    # Quick deploy (default) - Interactive
    .\Invoke-Navigator-Enhanced.ps1

.EXAMPLE
    # Quick deploy with parameters
    .\Invoke-Navigator-Enhanced.ps1 -Mode Quick -BotName "Sales Assistant" -Target "UAT"

.EXAMPLE
    # Quick deploy shorthand
    .\Invoke-Navigator-Enhanced.ps1 quick

.EXAMPLE
    # Full migration to production
    .\Invoke-Navigator-Enhanced.ps1 -Mode Full -Target "Production"

.EXAMPLE
    # Full migration shorthand
    .\Invoke-Navigator-Enhanced.ps1 full

.NOTES
    Author: Copilot Zapper Team
    Version: 2.0.0
    Requires: Azure CLI, PowerShell 7.0+
#>

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$Command,  # Can be: "quick", "full", "test", "deploy", "migrate", "production", or bot name

    [ValidateSet('Quick', 'Full')]
    [string]$Mode = 'Quick',  # Default to Quick for testing

    [string]$BotName,
    [string]$Source = 'Development',
    [string]$Target,

    [switch]$OpenTestChat,
    [switch]$NoConfirm
)

# Banner
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🧭 NAVIGATOR v2.0 - Copilot Deployment Tool" -ForegroundColor Cyan
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
        '^(quick|test|deploy)$' {
            $Mode = 'Quick'
            Write-Verbose "Mode set to Quick via command: $Command"
        }
        '^(full|migrate|production)$' {
            $Mode = 'Full'
            Write-Verbose "Mode set to Full via command: $Command"
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

# Smart mode detection - Production always uses Full mode
if ($Target -eq 'Production' -and $Mode -eq 'Quick') {
    Write-Host "🔒 Target is Production - automatically switching to Full mode for safety" -ForegroundColor Yellow
    Write-Host ""
    $Mode = 'Full'
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
if ($Mode -eq 'Quick') {
    Write-Host "Quick " -NoNewline -ForegroundColor Green
    Write-Host "(fast, no solution, ~30-60s)" -ForegroundColor Gray
} else {
    Write-Host "Full " -NoNewline -ForegroundColor Magenta
    Write-Host "(comprehensive, with solution, ~4-8min)" -ForegroundColor Gray
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
        'Quick' {
            # Quick Deploy Mode
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
            Write-Host "⚡ QUICK DEPLOY MODE" -ForegroundColor Green
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green

            $result = Invoke-QuickDeploy `
                -BotName $BotName `
                -SourceEnvironment $Source `
                -TargetEnvironment $Target `
                -OpenTestChat:$OpenTestChat

            Write-Host ""
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
            Write-Host "✅ QUICK DEPLOY COMPLETE" -ForegroundColor Green
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
            Write-Host ""
            Write-Host "  Time:   $($result.Duration)" -ForegroundColor White
            Write-Host "  Action: $($result.Action)" -ForegroundColor White
            Write-Host "  Bot ID: $($result.BotId)" -ForegroundColor Gray
            Write-Host ""
            Write-Host "🔗 Test URL:" -ForegroundColor Cyan
            Write-Host "  $($result.TestUrl)" -ForegroundColor White
            Write-Host ""
            Write-Host "💡 Tip: The copilot was deployed directly (no solution). To delete, just remove the bot from $Target." -ForegroundColor Gray
            Write-Host ""
        }

        'Full' {
            # Full Migration Mode
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
            Write-Host "📦 FULL MIGRATION MODE" -ForegroundColor Magenta
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
            Write-Host ""
            Write-Host "⚠️  Full migration mode will use the original Navigator (v1.0) script" -ForegroundColor Yellow
            Write-Host "    with solution packaging and comprehensive migration." -ForegroundColor Yellow
            Write-Host ""

            # Call original Navigator script for Full mode
            $originalScript = Join-Path $PSScriptRoot "Invoke-Navigator.ps1"

            if (Test-Path $originalScript) {
                Write-Host "Launching original Navigator for full migration..." -ForegroundColor Cyan
                Write-Host ""

                # Execute original Navigator
                & $originalScript
            }
            else {
                Write-Error "Original Navigator script not found at: $originalScript"
                Write-Host ""
                Write-Host "Please ensure Invoke-Navigator.ps1 exists for Full migration mode." -ForegroundColor Yellow
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
