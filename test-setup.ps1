#Requires -Version 7.0
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Navigator Prerequisites Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell version
Write-Host "1. PowerShell Version:" -NoNewline
$version = $PSVersionTable.PSVersion
if ($version.Major -ge 7) {
    Write-Host " ✅ $version" -ForegroundColor Green
} else {
    Write-Host " ❌ $version (Need 7.0+)" -ForegroundColor Red
}

# Check Azure CLI
Write-Host "2. Azure CLI:" -NoNewline
try {
    $azVersion = az version --query '"azure-cli"' -o tsv 2>$null
    if ($azVersion) {
        Write-Host " ✅ $azVersion" -ForegroundColor Green
    } else {
        Write-Host " ❌ Not found" -ForegroundColor Red
    }
} catch {
    Write-Host " ❌ Not installed" -ForegroundColor Red
}

# Check authentication
Write-Host "3. Azure Authentication:" -NoNewline
try {
    $account = az account show 2>$null | ConvertFrom-Json
    if ($account) {
        Write-Host " ✅ $($account.user.name)" -ForegroundColor Green
    } else {
        Write-Host " ❌ Not logged in" -ForegroundColor Yellow
        Write-Host "   Run: az login" -ForegroundColor Gray
    }
} catch {
    Write-Host " ❌ Not authenticated" -ForegroundColor Yellow
}

# Check files
Write-Host "4. Required Files:" -ForegroundColor White
$requiredFiles = @(
    "Invoke-Navigator.ps1",
    "Start-Navigator.ps1",
    "Demo-Navigator.ps1",
    "install-skill.ps1",
    "Modules\Copilot-Analysis.psm1",
    "skills\navigator.md"
)

foreach ($file in $requiredFiles) {
    Write-Host "   $file : " -NoNewline
    if (Test-Path $file) {
        Write-Host "✅" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
