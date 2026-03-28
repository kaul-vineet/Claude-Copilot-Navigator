#Requires -Version 7.0

<#
.SYNOPSIS
    Installs Navigator skill system-wide for Claude Code

.DESCRIPTION
    Copies skill files to Claude Code's skill directory and registers
    the /navigator command for copilot migration.

.PARAMETER Uninstall
    Remove the Navigator skill from Claude Code

.PARAMETER Update
    Update existing installation to latest version

.EXAMPLE
    .\install-skill.ps1
    Installs the Navigator skill

.EXAMPLE
    .\install-skill.ps1 -Uninstall
    Removes the Navigator skill

.EXAMPLE
    .\install-skill.ps1 -Update
    Updates existing installation

.NOTES
    Author: Copilot Zapper Team
    Version: 1.0.0
    Requires: PowerShell 7.0+, Azure CLI
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage="Remove the skill from Claude Code")]
    [switch]$Uninstall,

    [Parameter(HelpMessage="Update existing installation")]
    [switch]$Update
)

$ErrorActionPreference = "Stop"

# Configuration
$skillName = "navigator"
$skillVersion = "1.0.0"
$claudeDir = Join-Path $env:USERPROFILE ".claude"
$skillsDir = Join-Path $claudeDir "skills\$skillName"
$sourceDir = $PSScriptRoot

# Banner
function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     🎖️  NAVIGATOR SKILL INSTALLER  🎖️                      ║" -ForegroundColor Yellow
    Write-Host "║                                                          ║" -ForegroundColor Cyan
    Write-Host "║     Copilot Migration Commander for Claude Code         ║" -ForegroundColor White
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# Uninstall
function Remove-NavigatorSkill {
    Write-Host "🗑️  Uninstalling Navigator skill..." -ForegroundColor Yellow
    Write-Host ""

    if (Test-Path $skillsDir) {
        Remove-Item -Path $skillsDir -Recurse -Force
        Write-Host "✅ Navigator skill uninstalled from: $skillsDir" -ForegroundColor Green
        Write-Host ""
        Write-Host "Skill removed successfully. Restart Claude Code to complete uninstallation." -ForegroundColor Gray
    } else {
        Write-Host "⚠️  Navigator skill not found at: $skillsDir" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "The skill may not be installed or was already removed." -ForegroundColor Gray
    }

    Write-Host ""
}

# Check prerequisites
function Test-Prerequisites {
    Write-Host "🔍 Checking prerequisites..." -ForegroundColor Cyan
    Write-Host ""

    $allGood = $true

    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Host "❌ PowerShell 7.0+ required (current: $($PSVersionTable.PSVersion))" -ForegroundColor Red
        Write-Host "   Download: https://aka.ms/powershell" -ForegroundColor Gray
        $allGood = $false
    } else {
        Write-Host "✅ PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Green
    }

    # Check Azure CLI
    $azPath = "C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd"
    if (Test-Path $azPath) {
        Write-Host "✅ Azure CLI found" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Azure CLI not found (required for skill to function)" -ForegroundColor Yellow
        Write-Host "   Install: winget install Microsoft.AzureCLI" -ForegroundColor Gray
    }

    # Check source files
    $requiredFiles = @(
        "skills\navigator.md",
        "README.md"
    )

    $missingFiles = @()
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $sourceDir $file
        if (-not (Test-Path $filePath)) {
            $missingFiles += $file
        }
    }

    if ($missingFiles.Count -gt 0) {
        Write-Host "❌ Missing required files:" -ForegroundColor Red
        $missingFiles | ForEach-Object { Write-Host "   - $_" -ForegroundColor Gray }
        $allGood = $false
    } else {
        Write-Host "✅ All skill files present" -ForegroundColor Green
    }

    Write-Host ""
    return $allGood
}

# Install skill
function Install-NavigatorSkill {
    param([bool]$IsUpdate = $false)

    $action = if ($IsUpdate) { "Updating" } else { "Installing" }

    Write-Host "🎖️  $action Navigator - Copilot Migration Commander" -ForegroundColor Cyan
    Write-Host "   Version: $skillVersion" -ForegroundColor Gray
    Write-Host ""

    # Create Claude skills directory
    if (-not (Test-Path $claudeDir)) {
        Write-Host "📁 Creating Claude directory..." -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    }

    if (-not (Test-Path $skillsDir)) {
        Write-Host "📁 Creating skill directory..." -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
        Write-Host "   ✅ Created: $skillsDir" -ForegroundColor Green
    } elseif ($IsUpdate) {
        Write-Host "📁 Updating existing installation..." -ForegroundColor Cyan
    } else {
        Write-Host "⚠️  Skill directory already exists. Use -Update to update." -ForegroundColor Yellow
        $response = Read-Host "   Overwrite existing installation? (Y/N)"
        if ($response -ne 'Y' -and $response -ne 'y') {
            Write-Host ""
            Write-Host "Installation cancelled." -ForegroundColor Yellow
            return $false
        }
    }

    Write-Host ""
    Write-Host "📋 Copying skill files..." -ForegroundColor Cyan

    # Copy main skill definition
    $skillFile = Join-Path $sourceDir "skills\navigator.md"
    if (Test-Path $skillFile) {
        Copy-Item -Path $skillFile -Destination $skillsDir -Force
        Write-Host "   ✅ navigator.md" -ForegroundColor Green
    }

    # Copy helper scripts
    $helpers = Get-ChildItem -Path $sourceDir -Filter "*.ps1" -File | Where-Object {
        $_.Name -match '^\..*\.ps1$' -or $_.Name -eq "install-skill.ps1"
    }

    foreach ($helper in $helpers) {
        Copy-Item -Path $helper.FullName -Destination $skillsDir -Force
        Write-Host "   ✅ $($helper.Name)" -ForegroundColor Green
    }

    # Copy documentation
    $docs = @("README.md", "QUICK_START.md", "LICENSE", "DISTRIBUTION.md")
    foreach ($doc in $docs) {
        $docPath = Join-Path $sourceDir $doc
        if (Test-Path $docPath) {
            Copy-Item -Path $docPath -Destination $skillsDir -Force
            Write-Host "   ✅ $doc" -ForegroundColor Green
        }
    }

    # Create version info
    $versionInfo = @{
        version = $skillVersion
        installedOn = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        installedFrom = $sourceDir
    } | ConvertTo-Json

    $versionInfo | Out-File -FilePath (Join-Path $skillsDir "version.json") -Encoding UTF8

    return $true
}

# Main execution
try {
    Show-Banner

    if ($Uninstall) {
        Remove-NavigatorSkill
        exit 0
    }

    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Host "❌ Prerequisites not met. Please install required components and try again." -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Install or update
    $success = Install-NavigatorSkill -IsUpdate:$Update

    if ($success) {
        Write-Host ""
        Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║     🎖️  NAVIGATOR SKILL INSTALLED SUCCESSFULLY  🎖️        ║" -ForegroundColor Green
        Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host ""
        Write-Host "📍 Installed to: $skillsDir" -ForegroundColor Gray
        Write-Host ""
        Write-Host "🚀 To use the skill:" -ForegroundColor White
        Write-Host "   1. Restart Claude Code (if running)" -ForegroundColor Gray
        Write-Host "   2. Open a conversation" -ForegroundColor Gray
        Write-Host "   3. Type: /navigator" -ForegroundColor Yellow
        Write-Host "   4. Follow the interactive prompts!" -ForegroundColor Gray
        Write-Host ""
        Write-Host "📖 Documentation:" -ForegroundColor White
        Write-Host "   - README: $skillsDir\README.md" -ForegroundColor Gray
        Write-Host "   - Quick Start: $skillsDir\QUICK_START.md" -ForegroundColor Gray
        Write-Host ""
        Write-Host "🔧 Management:" -ForegroundColor White
        Write-Host "   - Update: .\install-skill.ps1 -Update" -ForegroundColor Gray
        Write-Host "   - Uninstall: .\install-skill.ps1 -Uninstall" -ForegroundColor Gray
        Write-Host ""
        Write-Host "*'In the desert, the tank is king' - Navigator* 🎖️" -ForegroundColor Cyan
        Write-Host ""
    }
}
catch {
    Write-Host ""
    Write-Host "❌ Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Stack trace:" -ForegroundColor Gray
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
    Write-Host ""
    exit 1
}
