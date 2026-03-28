#Requires -Version 7.0
<#
.SYNOPSIS
    Quick launcher for Navigator - Copilot Migration Commander

.DESCRIPTION
    Simple wrapper script that performs prerequisite checks and launches Navigator.

.EXAMPLE
    .\Start-Navigator.ps1

.NOTES
    This script checks for prerequisites before launching the main tool.
#>

[CmdletBinding()]
param()

function Test-Prerequisites {
    $allGood = $true

    Write-Host ""
    Write-Host "🔍 Checking prerequisites..." -ForegroundColor Cyan
    Write-Host ""

    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Host "❌ PowerShell 7.0 or higher required" -ForegroundColor Red
        Write-Host "   Current version: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
        Write-Host "   Download from: https://aka.ms/powershell" -ForegroundColor Gray
        $allGood = $false
    } else {
        Write-Host "✅ PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Green
    }

    # Check Azure CLI
    try {
        $azVersion = az version 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $versionInfo = (az version | ConvertFrom-Json).'azure-cli'
            Write-Host "✅ Azure CLI $versionInfo" -ForegroundColor Green
        } else {
            throw
        }
    }
    catch {
        Write-Host "❌ Azure CLI not found" -ForegroundColor Red
        Write-Host "   Download from: https://aka.ms/installazurecli" -ForegroundColor Gray
        $allGood = $false
    }

    # Check if Invoke-Navigator.ps1 exists
    $scriptPath = Join-Path $PSScriptRoot "Invoke-Navigator.ps1"
    if (Test-Path $scriptPath) {
        Write-Host "✅ Navigator script found" -ForegroundColor Green
    } else {
        Write-Host "❌ Invoke-Navigator.ps1 not found in current directory" -ForegroundColor Red
        $allGood = $false
    }

    # Check Azure login status
    try {
        $account = az account show 2>&1 | ConvertFrom-Json
        Write-Host "✅ Authenticated as: $($account.user.name)" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  Not authenticated with Azure CLI" -ForegroundColor Yellow
        Write-Host "   Run 'az login' before proceeding" -ForegroundColor Gray

        $login = Read-Host "   Attempt login now? (Y/N)"
        if ($login -eq 'Y' -or $login -eq 'y') {
            az login
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Authentication successful" -ForegroundColor Green
            } else {
                $allGood = $false
            }
        } else {
            $allGood = $false
        }
    }

    Write-Host ""
    return $allGood
}

function Show-Welcome {
    Clear-Host
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                                  ║" -ForegroundColor Cyan
    Write-Host "║          🎖️  NAVIGATOR - COPILOT MIGRATION COMMANDER  🎖️            ║" -ForegroundColor Yellow
    Write-Host "║                                                                  ║" -ForegroundColor Cyan
    Write-Host "║          Strategic Migration for Copilot Studio                 ║" -ForegroundColor White
    Write-Host "║                                                                  ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Version: 1.0.0" -ForegroundColor Gray
    Write-Host "  Author: Copilot Zapper Team" -ForegroundColor Gray
    Write-Host ""
}

# Main execution
try {
    Show-Welcome

    if (Test-Prerequisites) {
        Write-Host "🚀 Launching Navigator..." -ForegroundColor Green
        Write-Host ""
        Start-Sleep -Seconds 1

        $scriptPath = Join-Path $PSScriptRoot "Invoke-Navigator.ps1"
        & $scriptPath
    } else {
        Write-Host ""
        Write-Host "⚠️  Prerequisites not met. Please install required components and try again." -ForegroundColor Red
        Write-Host ""
    }
}
catch {
    Write-Host ""
    Write-Host "❌ An error occurred: $_" -ForegroundColor Red
    Write-Host ""
}
finally {
    if ($Host.Name -eq 'ConsoleHost') {
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}
