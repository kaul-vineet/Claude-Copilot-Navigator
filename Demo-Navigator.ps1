#Requires -Version 7.0
<#
.SYNOPSIS
    Demo version of Navigator - Shows capabilities without interactive console

.DESCRIPTION
    Demonstrates Navigator's features and validates environment setup
#>

[CmdletBinding()]
param()

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "          NAVIGATOR - COPILOT MIGRATION COMMANDER" -ForegroundColor Yellow
Write-Host "          Demo Mode - Environment Validation" -ForegroundColor White
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell version
Write-Host "Checking Prerequisites..." -ForegroundColor Cyan
Write-Host ""
Write-Host "  PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Green
Write-Host "  Operating System: $($PSVersionTable.OS)" -ForegroundColor Green
Write-Host ""

# Check Azure CLI
Write-Host "Checking Azure CLI..." -ForegroundColor Cyan
try {
    $azVersion = az version 2>&1 | ConvertFrom-Json
    Write-Host "  Azure CLI Version: $($azVersion.'azure-cli')" -ForegroundColor Green

    # Check if logged in
    try {
        $account = az account show 2>&1 | ConvertFrom-Json
        Write-Host "  Status: Authenticated" -ForegroundColor Green
        Write-Host "  User: $($account.user.name)" -ForegroundColor White
        Write-Host "  Tenant: $($account.tenantId)" -ForegroundColor White
    }
    catch {
        Write-Host "  Status: Not authenticated" -ForegroundColor Yellow
        Write-Host "  Action Required: Run 'az login' to authenticate" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "  Azure CLI: Not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Feature Overview:" -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Interactive Environment Selection" -ForegroundColor White
Write-Host "     - Lists all Power Platform environments" -ForegroundColor Gray
Write-Host "     - Beautiful table display" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Copilot Discovery & Selection" -ForegroundColor White
Write-Host "     - Shows all copilots in source environment" -ForegroundColor Gray
Write-Host "     - Displays creation date and status" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Migration Type Selection" -ForegroundColor White
Write-Host "     - Template Only (structure)" -ForegroundColor Gray
Write-Host "     - Full Copilot (everything)" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. Parameter Customization" -ForegroundColor White
Write-Host "     - Modify bot name, description, language, schema" -ForegroundColor Gray
Write-Host ""
Write-Host "  5. Migration Execution" -ForegroundColor White
Write-Host "     - Real-time progress bars" -ForegroundColor Gray
Write-Host "     - Automatic report generation" -ForegroundColor Gray
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "To run the full interactive version:" -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Open PowerShell 7 (the blue icon)" -ForegroundColor White
Write-Host "  2. cd C:\code\copilot-zapper" -ForegroundColor Gray
Write-Host "  3. .\Start-Navigator.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Or run directly:" -ForegroundColor White
Write-Host "  .\Invoke-Navigator.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
