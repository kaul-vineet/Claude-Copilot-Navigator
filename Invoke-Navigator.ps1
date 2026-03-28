#Requires -Version 7.0
<#
.SYNOPSIS
    Navigator - Copilot Migration Pathfinder

.DESCRIPTION
    Guides Microsoft Copilot Studio copilots and templates through migrations
    between Power Platform environments with precision and clarity.
    Includes migration and comprehensive analysis capabilities.

.EXAMPLE
    .\Invoke-Navigator.ps1

.NOTES
    Author: Copilot Zapper Team
    Version: 1.0.0
    Requires: Azure CLI, PowerShell 7.0+
#>

[CmdletBinding()]
param()

#region UI Functions

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                                  ║" -ForegroundColor Cyan
    Write-Host "║          🧭  NAVIGATOR - COPILOT MIGRATION PATHFINDER  🧭        ║" -ForegroundColor Yellow
    Write-Host "║                                                                  ║" -ForegroundColor Cyan
    Write-Host "║       'Every journey begins with a single step' - Lao Tzu       ║" -ForegroundColor Gray
    Write-Host "║                                                                  ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-SectionHeader {
    param([string]$Title, [string]$Icon = "📌")
    Write-Host ""
    Write-Host "┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "│ $Icon  $Title" -ForegroundColor White
    Write-Host "└─────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
    Write-Host ""
}

function Show-Menu {
    param(
        [string]$Title,
        [string[]]$Options,
        [string]$Icon = "▶"
    )

    Write-Host "  $Title" -ForegroundColor Yellow
    Write-Host ""

    for ($i = 0; $i -lt $Options.Length; $i++) {
        Write-Host "    [$($i + 1)] $Icon $($Options[$i])" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "    [0] $Icon Back/Cancel" -ForegroundColor DarkGray
    Write-Host ""
}

function Get-MenuSelection {
    param(
        [int]$MaxOption,
        [string]$Prompt = "Select option"
    )

    do {
        $selection = Read-Host "  $Prompt (0-$MaxOption)"
        $valid = $selection -match '^\d+$' -and [int]$selection -ge 0 -and [int]$selection -le $MaxOption
        if (-not $valid) {
            Write-Host "  ⚠️  Invalid selection. Please enter a number between 0 and $MaxOption" -ForegroundColor Red
        }
    } while (-not $valid)

    return [int]$selection
}

function Show-Progress {
    param(
        [string]$Activity,
        [string]$Status,
        [int]$PercentComplete
    )

    $barLength = 50
    $filledLength = [Math]::Floor($barLength * $PercentComplete / 100)
    $emptyLength = $barLength - $filledLength

    $bar = "█" * $filledLength + "░" * $emptyLength

    Write-Host "`r  🔄 $Activity" -NoNewline -ForegroundColor Cyan
    Write-Host "`n  [$bar] $PercentComplete% - $Status" -NoNewline -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  ℹ️  $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "  ⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "  ❌ $Message" -ForegroundColor Red
}

function Show-DataTable {
    param(
        [array]$Data,
        [string[]]$Properties
    )

    Write-Host ""
    $Data | Format-Table -Property $Properties -AutoSize | Out-String | Write-Host
}

#endregion

#region Authentication Functions

function Test-AzureCLI {
    Show-SectionHeader -Title "Authentication Check" -Icon "🔐"

    try {
        $null = az account show 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Azure CLI not authenticated"
            Write-Info "Please run: az login"
            return $false
        }

        $account = az account show | ConvertFrom-Json
        Write-Success "Authenticated as: $($account.user.name)"
        Write-Info "Tenant: $($account.tenantId)"
        return $true
    }
    catch {
        Write-Error "Azure CLI not found. Please install Azure CLI first."
        return $false
    }
}

function Get-AccessToken {
    param([string]$Resource = "https://api.bap.microsoft.com/")

    try {
        $token = az account get-access-token --resource $Resource --query accessToken -o tsv
        if ($LASTEXITCODE -eq 0 -and $token) {
            return $token
        }
        throw "Failed to get access token"
    }
    catch {
        Write-Error "Failed to retrieve access token: $_"
        return $null
    }
}

#endregion

#region Power Platform API Functions

function Get-PowerPlatformEnvironments {
    param([string]$AccessToken)

    try {
        $headers = @{
            "Authorization" = "Bearer $AccessToken"
            "Content-Type" = "application/json"
        }

        $uri = "https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments?api-version=2021-04-01"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        return $response.value
    }
    catch {
        Write-Error "Failed to retrieve environments: $_"
        return @()
    }
}

function Get-CopilotStudioBots {
    param(
        [string]$EnvironmentUrl,
        [string]$AccessToken
    )

    try {
        # Get Dataverse access token
        $dvToken = Get-AccessToken -Resource $EnvironmentUrl

        $headers = @{
            "Authorization" = "Bearer $dvToken"
            "Content-Type" = "application/json"
            "OData-MaxVersion" = "4.0"
            "OData-Version" = "4.0"
        }

        # Query for Copilot Studio bots
        $uri = "$EnvironmentUrl/api/data/v9.2/bots?`$select=name,botid,createdon,statecode,statuscode&`$orderby=createdon desc"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        return $response.value
    }
    catch {
        Write-Error "Failed to retrieve copilots: $_"
        return @()
    }
}

function Get-BotComponents {
    param(
        [string]$EnvironmentUrl,
        [string]$BotId,
        [string]$AccessToken
    )

    try {
        $dvToken = Get-AccessToken -Resource $EnvironmentUrl

        $headers = @{
            "Authorization" = "Bearer $dvToken"
            "Content-Type" = "application/json"
            "OData-MaxVersion" = "4.0"
            "OData-Version" = "4.0"
        }

        $components = @{
            Topics = @()
            Triggers = @()
            Skills = @()
            KnowledgeSources = @()
        }

        # Get bot components (topics, triggers, etc.)
        $uri = "$EnvironmentUrl/api/data/v9.2/botcomponents?`$filter=_parentbotid_value eq $BotId"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        foreach ($component in $response.value) {
            switch ($component.componenttype) {
                0 { $components.Topics += $component }
                1 { $components.Triggers += $component }
                2 { $components.Skills += $component }
            }
        }

        return $components
    }
    catch {
        Write-Error "Failed to retrieve bot components: $_"
        return $null
    }
}

function Export-BotDefinition {
    param(
        [string]$EnvironmentUrl,
        [string]$BotId,
        [string]$BotName,
        [bool]$TemplateOnly = $false
    )

    try {
        $dvToken = Get-AccessToken -Resource $EnvironmentUrl

        $headers = @{
            "Authorization" = "Bearer $dvToken"
            "Content-Type" = "application/json"
        }

        Show-Progress -Activity "Exporting Bot" -Status "Fetching bot definition..." -PercentComplete 20

        # Get full bot definition
        $uri = "$EnvironmentUrl/api/data/v9.2/bots($BotId)"
        $bot = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        Show-Progress -Activity "Exporting Bot" -Status "Fetching components..." -PercentComplete 40

        # Get components
        $components = Get-BotComponents -EnvironmentUrl $EnvironmentUrl -BotId $BotId -AccessToken $dvToken

        Show-Progress -Activity "Exporting Bot" -Status "Building export package..." -PercentComplete 60

        $exportData = @{
            Bot = $bot
            Components = $components
            IsTemplate = $TemplateOnly
            ExportedOn = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            ExportedFrom = $EnvironmentUrl
        }

        Show-Progress -Activity "Exporting Bot" -Status "Saving to file..." -PercentComplete 80

        # Save to JSON file
        $fileName = "$BotName-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
        $exportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $fileName -Encoding UTF8

        Show-Progress -Activity "Exporting Bot" -Status "Complete!" -PercentComplete 100
        Write-Host ""
        Write-Success "Export saved to: $fileName"

        return $fileName
    }
    catch {
        Write-Host ""
        Write-Error "Export failed: $_"
        return $null
    }
}

function Import-BotDefinition {
    param(
        [string]$EnvironmentUrl,
        [string]$ExportFile,
        [hashtable]$Parameters
    )

    try {
        $dvToken = Get-AccessToken -Resource $EnvironmentUrl

        $headers = @{
            "Authorization" = "Bearer $dvToken"
            "Content-Type" = "application/json"
            "OData-MaxVersion" = "4.0"
            "OData-Version" = "4.0"
        }

        Show-Progress -Activity "Importing Bot" -Status "Reading export file..." -PercentComplete 10

        $exportData = Get-Content -Path $ExportFile -Raw | ConvertFrom-Json

        Show-Progress -Activity "Importing Bot" -Status "Preparing bot definition..." -PercentComplete 30

        # Apply parameter changes
        $botData = $exportData.Bot | ConvertTo-Json -Depth 10 | ConvertFrom-Json

        foreach ($key in $Parameters.Keys) {
            if ($botData.PSObject.Properties.Name -contains $key) {
                $botData.$key = $Parameters[$key]
            }
        }

        # Remove system fields
        $botData.PSObject.Properties.Remove('botid')
        $botData.PSObject.Properties.Remove('createdon')
        $botData.PSObject.Properties.Remove('modifiedon')

        Show-Progress -Activity "Importing Bot" -Status "Creating bot..." -PercentComplete 50

        # Create bot
        $uri = "$EnvironmentUrl/api/data/v9.2/bots"
        $newBot = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($botData | ConvertTo-Json -Depth 10)

        $newBotId = $newBot.botid

        if (-not $exportData.IsTemplate) {
            Show-Progress -Activity "Importing Bot" -Status "Importing components..." -PercentComplete 70

            # Import components (topics, triggers, etc.)
            $componentCount = 0
            $totalComponents = ($exportData.Components.Topics.Count +
                               $exportData.Components.Triggers.Count +
                               $exportData.Components.Skills.Count)

            foreach ($topic in $exportData.Components.Topics) {
                $componentData = $topic | ConvertTo-Json -Depth 10 | ConvertFrom-Json

                # Remove system fields
                $componentData.PSObject.Properties.Remove('botcomponentid')
                $componentData.PSObject.Properties.Remove('_parentbotid_value')

                # Use OData navigation property instead of direct reference
                $componentData | Add-Member -MemberType NoteProperty -Name "parentbotid@odata.bind" -Value "/bots($newBotId)" -Force

                $uri = "$EnvironmentUrl/api/data/v9.2/botcomponents"
                $null = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($componentData | ConvertTo-Json -Depth 10)

                $componentCount++
                $progress = 70 + ([Math]::Floor(($componentCount / $totalComponents) * 20))
                Show-Progress -Activity "Importing Bot" -Status "Importing component $componentCount of $totalComponents..." -PercentComplete $progress
            }
        }

        Show-Progress -Activity "Importing Bot" -Status "Publishing bot..." -PercentComplete 95

        # Publish bot
        $publishUri = "$EnvironmentUrl/api/data/v9.2/bots($newBotId)/Microsoft.Dynamics.CRM.PublishBot"
        $null = Invoke-RestMethod -Uri $publishUri -Headers $headers -Method Post

        Show-Progress -Activity "Importing Bot" -Status "Complete!" -PercentComplete 100
        Write-Host ""
        Write-Success "Bot imported successfully!"
        Write-Info "New Bot ID: $newBotId"

        return $newBotId
    }
    catch {
        Write-Host ""
        Write-Error "Import failed: $_"
        return $null
    }
}

#endregion

#region Migration Parameters

function Get-MigrationParameters {
    param([object]$Bot)

    Show-SectionHeader -Title "Migration Parameters" -Icon "⚙️"

    Write-Info "Current bot configuration:"
    Write-Host ""
    Write-Host "  Name: $($Bot.name)" -ForegroundColor White
    Write-Host "  State: $($Bot.statecode)" -ForegroundColor White
    Write-Host ""

    $parameters = @{}

    # Ask for parameter changes
    Show-Menu -Title "Which parameters would you like to modify?" -Options @(
        "Bot Name",
        "Description",
        "Language",
        "Schema Name",
        "Continue without changes"
    ) -Icon "🔧"

    $choice = Get-MenuSelection -MaxOption 5 -Prompt "Select parameter to modify"

    while ($choice -ne 0 -and $choice -ne 5) {
        switch ($choice) {
            1 {
                $newName = Read-Host "  Enter new bot name (current: $($Bot.name))"
                if ($newName) { $parameters['name'] = $newName }
            }
            2 {
                $newDesc = Read-Host "  Enter new description"
                if ($newDesc) { $parameters['description'] = $newDesc }
            }
            3 {
                $newLang = Read-Host "  Enter language code (e.g., 1033 for English)"
                if ($newLang) { $parameters['language'] = [int]$newLang }
            }
            4 {
                $newSchema = Read-Host "  Enter new schema name"
                if ($newSchema) { $parameters['schemaname'] = $newSchema }
            }
        }

        Show-Menu -Title "Modify another parameter?" -Options @(
            "Bot Name",
            "Description",
            "Language",
            "Schema Name",
            "Continue with current parameters"
        ) -Icon "🔧"

        $choice = Get-MenuSelection -MaxOption 5 -Prompt "Select parameter to modify"
    }

    if ($parameters.Count -gt 0) {
        Write-Success "Parameters configured: $($parameters.Keys -join ', ')"
    } else {
        Write-Info "No parameter changes requested"
    }

    return $parameters
}

#endregion

#region Main Workflow

function Start-MigrationWorkflow {
    Show-Banner

    # Step 1: Authenticate
    if (-not (Test-AzureCLI)) {
        Write-Warning "Please authenticate with Azure CLI and try again"
        return
    }

    # Step 2: Get source environment
    Show-SectionHeader -Title "Source Environment Selection" -Icon "🎯"

    $bapToken = Get-AccessToken -Resource "https://api.bap.microsoft.com/"
    if (-not $bapToken) {
        Write-Error "Failed to get access token"
        return
    }

    Write-Info "Fetching environments..."
    $environments = Get-PowerPlatformEnvironments -AccessToken $bapToken

    if ($environments.Count -eq 0) {
        Write-Error "No environments found"
        return
    }

    $envOptions = $environments | ForEach-Object { "$($_.properties.displayName) ($($_.name))" }
    Show-Menu -Title "Select Source Environment" -Options $envOptions -Icon "🌐"

    $envChoice = Get-MenuSelection -MaxOption $environments.Count -Prompt "Select source environment"
    if ($envChoice -eq 0) {
        Write-Warning "Migration cancelled"
        return
    }

    $sourceEnv = $environments[$envChoice - 1]
    $sourceUrl = $sourceEnv.properties.linkedEnvironmentMetadata.instanceUrl

    Write-Success "Source: $($sourceEnv.properties.displayName)"

    # Step 3: Get copilots from source
    Show-SectionHeader -Title "Copilot Selection" -Icon "🤖"

    Write-Info "Fetching copilots from source environment..."
    $bots = Get-CopilotStudioBots -EnvironmentUrl $sourceUrl -AccessToken $bapToken

    if ($bots.Count -eq 0) {
        Write-Warning "No copilots found in source environment"
        return
    }

    Write-Success "Found $($bots.Count) copilot(s)"

    # Display copilots in table
    $botsDisplay = $bots | Select-Object @{N='#';E={$bots.IndexOf($_) + 1}}, name, createdon, statecode
    Show-DataTable -Data $botsDisplay -Properties '#', 'name', 'createdon', 'statecode'

    $botChoice = Read-Host "  Select copilot number (1-$($bots.Count), 0 to cancel)"
    if ([int]$botChoice -eq 0) {
        Write-Warning "Migration cancelled"
        return
    }

    $selectedBot = $bots[[int]$botChoice - 1]
    Write-Success "Selected: $($selectedBot.name)"

    # Step 4: Migration type
    Show-SectionHeader -Title "Migration Type" -Icon "🔄"

    Show-Menu -Title "What would you like to migrate?" -Options @(
        "Template Only (bot structure, no content)",
        "Full Copilot (everything including topics, knowledge)"
    ) -Icon "📦"

    $migType = Get-MenuSelection -MaxOption 2 -Prompt "Select migration type"
    if ($migType -eq 0) {
        Write-Warning "Migration cancelled"
        return
    }

    $isTemplate = ($migType -eq 1)
    $migrationType = if ($isTemplate) { "Template" } else { "Full Copilot" }
    Write-Success "Migration type: $migrationType"

    # Step 5: Parameter customization
    $parameters = Get-MigrationParameters -Bot $selectedBot

    # Step 6: Target environment selection
    Show-SectionHeader -Title "Target Environment Selection" -Icon "🎯"

    Show-Menu -Title "Select Target Environment" -Options $envOptions -Icon "🌐"

    $targetEnvChoice = Get-MenuSelection -MaxOption $environments.Count -Prompt "Select target environment"
    if ($targetEnvChoice -eq 0) {
        Write-Warning "Migration cancelled"
        return
    }

    $targetEnv = $environments[$targetEnvChoice - 1]
    $targetUrl = $targetEnv.properties.linkedEnvironmentMetadata.instanceUrl

    # Validate source and target are different
    if ($sourceEnv.name -eq $targetEnv.name) {
        Write-Error "Source and Target environments cannot be the same!"
        Write-Warning "Please select a different target environment."
        Write-Host ""
        Start-Sleep -Seconds 2

        # Restart workflow
        Start-MigrationWorkflow
        return
    }

    Write-Success "Target: $($targetEnv.properties.displayName)"

    # Step 7: Confirmation
    Show-SectionHeader -Title "Migration Summary" -Icon "📋"

    Write-Host "  Source Environment: " -NoNewline -ForegroundColor Gray
    Write-Host "$($sourceEnv.properties.displayName)" -ForegroundColor White

    Write-Host "  Target Environment: " -NoNewline -ForegroundColor Gray
    Write-Host "$($targetEnv.properties.displayName)" -ForegroundColor White

    Write-Host "  Copilot: " -NoNewline -ForegroundColor Gray
    Write-Host "$($selectedBot.name)" -ForegroundColor White

    Write-Host "  Migration Type: " -NoNewline -ForegroundColor Gray
    Write-Host "$migrationType" -ForegroundColor White

    if ($parameters.Count -gt 0) {
        Write-Host "  Parameter Changes: " -NoNewline -ForegroundColor Gray
        Write-Host "$($parameters.Keys -join ', ')" -ForegroundColor Yellow
    }

    Write-Host ""
    $confirm = Read-Host "  Proceed with migration? (Y/N)"

    if ($confirm -ne 'Y' -and $confirm -ne 'y') {
        Write-Warning "Migration cancelled by user"
        Write-Host ""
        Show-Menu -Title "What would you like to do?" -Options @(
            "Start over (select different copilot/settings)",
            "Exit Navigator"
        ) -Icon "🔄"

        $nextAction = Get-MenuSelection -MaxOption 2 -Prompt "Select action"

        if ($nextAction -eq 1) {
            Write-Info "Restarting migration workflow..."
            Start-Sleep -Seconds 1
            Start-MigrationWorkflow
            return
        } else {
            Write-Info "Exiting Navigator. Auf Wiedersehen! 🎖️"
            return
        }
    }

    # Step 8: Execute migration
    Show-SectionHeader -Title "Migration Execution" -Icon "🚀"

    # Export from source
    $exportFile = Export-BotDefinition -EnvironmentUrl $sourceUrl -BotId $selectedBot.botid -BotName $selectedBot.name -TemplateOnly $isTemplate

    if (-not $exportFile) {
        Write-Error "Export failed. Migration aborted."
        return
    }

    # Import to target
    $newBotId = Import-BotDefinition -EnvironmentUrl $targetUrl -ExportFile $exportFile -Parameters $parameters

    if ($newBotId) {
        Show-SectionHeader -Title "Migration Complete" -Icon "✅"

        Write-Success "Migration completed successfully!"
        Write-Info "Export file: $exportFile"
        Write-Info "New Bot ID: $newBotId"
        Write-Info "Target Environment: $($targetEnv.properties.displayName)"

        # Generate migration report
        $reportFile = "migration-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
        $report = @"
╔══════════════════════════════════════════════════════════════════╗
║              NAVIGATOR MIGRATION REPORT                             ║
╚══════════════════════════════════════════════════════════════════╝

Migration Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

SOURCE ENVIRONMENT:
  Name: $($sourceEnv.properties.displayName)
  URL: $sourceUrl

TARGET ENVIRONMENT:
  Name: $($targetEnv.properties.displayName)
  URL: $targetUrl

COPILOT:
  Original Name: $($selectedBot.name)
  Original ID: $($selectedBot.botid)
  New ID: $newBotId
  Migration Type: $migrationType

EXPORT FILE: $exportFile

PARAMETERS MODIFIED:
$(if ($parameters.Count -gt 0) {
    $parameters.GetEnumerator() | ForEach-Object { "  - $($_.Key): $($_.Value)" }
} else {
    "  None"
})

STATUS: SUCCESS ✅

"@

        $report | Out-File -FilePath $reportFile -Encoding UTF8
        Write-Success "Migration report saved: $reportFile"

        Write-Host ""
        Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║  🧭  Mission Accomplished - Navigator                            ║" -ForegroundColor Green
        Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host ""

        # Next action menu
        Show-Menu -Title "What would you like to do next?" -Options @(
            "Migrate another copilot",
            "Return to main menu",
            "Exit Navigator"
        ) -Icon "➡️"

        $nextChoice = Get-MenuSelection -MaxOption 3 -Prompt "Select next action"

        switch ($nextChoice) {
            1 { Start-MigrationWorkflow }
            2 { Start-MainMenu }
            3 { exit 0 }
            0 { Start-MainMenu }
        }
    }
}

#endregion

#region Analysis Workflow

function Start-AnalysisWorkflow {
    <#
    .SYNOPSIS
        Interactive copilot analysis workflow
    #>

    Show-Banner

    # Step 1: Authenticate
    if (-not (Test-AzureCLI)) {
        Write-Warning "Please authenticate with Azure CLI and try again"
        return
    }

    # Step 2: Select environment
    Show-SectionHeader -Title "Environment Selection" -Icon "🌐"

    $bapToken = Get-AccessToken -Resource "https://api.bap.microsoft.com/"
    if (-not $bapToken) {
        Write-Error "Failed to get access token"
        return
    }

    Write-Info "Fetching environments..."
    $environments = Get-PowerPlatformEnvironments -AccessToken $bapToken

    if ($environments.Count -eq 0) {
        Write-Error "No environments found"
        return
    }

    $envOptions = $environments | ForEach-Object { "$($_.properties.displayName) ($($_.name))" }
    Show-Menu -Title "Select Environment to Analyze" -Options $envOptions -Icon "🌐"

    $envChoice = Get-MenuSelection -MaxOption $environments.Count -Prompt "Select environment"
    if ($envChoice -eq 0) {
        Write-Warning "Analysis cancelled"
        Start-MainMenu
        return
    }

    $selectedEnv = $environments[$envChoice - 1]
    $envUrl = $selectedEnv.properties.linkedEnvironmentMetadata.instanceUrl

    Write-Success "Environment: $($selectedEnv.properties.displayName)"

    # Step 3: Get copilots
    Show-SectionHeader -Title "Copilot Selection" -Icon "🤖"

    Write-Info "Fetching copilots..."
    $bots = Get-CopilotStudioBots -EnvironmentUrl $envUrl -AccessToken $bapToken

    if ($bots.Count -eq 0) {
        Write-Warning "No copilots found in this environment"
        return
    }

    Write-Success "Found $($bots.Count) copilot(s)"

    # Display copilots in table
    $botsDisplay = $bots | Select-Object @{N='#';E={$bots.IndexOf($_) + 1}}, name, createdon, statecode
    Show-DataTable -Data $botsDisplay -Properties '#', 'name', 'createdon', 'statecode'

    $botChoice = Read-Host "  Select copilot number (1-$($bots.Count), 0 to cancel)"
    if ([int]$botChoice -eq 0) {
        Write-Warning "Analysis cancelled"
        Start-MainMenu
        return
    }

    $selectedBot = $bots[[int]$botChoice - 1]
    Write-Success "Selected: $($selectedBot.name)"

    # Step 4: Export copilot data
    Show-SectionHeader -Title "Analyzing Copilot" -Icon "🔍"

    Write-Info "Exporting copilot data for analysis..."
    Write-Host ""

    try {
        # Get access token for Dataverse
        $dvToken = Get-AccessToken -Resource $envUrl

        $headers = @{
            "Authorization" = "Bearer $dvToken"
            "Content-Type" = "application/json"
        }

        # Get bot definition
        $uri = "$envUrl/api/data/v9.2/bots($($selectedBot.botid))"
        $bot = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        # Get bot components
        $components = Get-BotComponents -EnvironmentUrl $envUrl -BotId $selectedBot.botid -AccessToken $dvToken

        # Convert components to array format expected by analysis module
        $componentsArray = @()
        if ($components.Topics) { $componentsArray += $components.Topics }
        if ($components.Triggers) { $componentsArray += $components.Triggers }
        if ($components.Skills) { $componentsArray += $components.Skills }

        # Build export data structure
        $exportData = @{
            bot = $bot
            components = $componentsArray
            _exportSize = 0
        }

        # Calculate approximate size
        $jsonData = $exportData | ConvertTo-Json -Depth 10 -Compress
        $exportData._exportSize = $jsonData.Length

        Write-Success "Data exported successfully"

        # Step 5: Perform analysis
        Write-Info "Analyzing copilot structure..."
        Write-Host ""

        # Import analysis module
        $modulePath = Join-Path $PSScriptRoot "Modules\Copilot-Analysis.psm1"
        if (Test-Path $modulePath) {
            Import-Module $modulePath -Force -ErrorAction Stop
        } else {
            Write-Error "Analysis module not found: $modulePath"
            return
        }

        # Analyze
        $analysis = Get-CopilotAnalysis -CopilotData $exportData -IncludeDetails

        # Display report
        Show-CopilotAnalysisReport -Analysis $analysis -Detailed

        # Step 6: Export options
        Show-SectionHeader -Title "Export Options" -Icon "💾"

        Show-Menu -Title "Would you like to save this analysis?" -Options @(
            "Save as Markdown (.md)",
            "Save as JSON (.json)",
            "Don't save, just view"
        ) -Icon "📄"

        $exportChoice = Get-MenuSelection -MaxOption 3 -Prompt "Select export option"

        if ($exportChoice -ne 3 -and $exportChoice -ne 0) {
            $format = switch ($exportChoice) {
                1 { "Markdown" }
                2 { "JSON" }
            }

            $outputPath = Read-Host "  Enter output directory (press Enter for current directory)"
            if ([string]::IsNullOrWhiteSpace($outputPath)) {
                $outputPath = Get-Location
            }

            if (-not (Test-Path $outputPath)) {
                New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
            }

            $savedFile = Export-CopilotAnalysisReport -Analysis $analysis -OutputPath $outputPath -Format $format
            Write-Success "Analysis saved to: $savedFile"
        }

        # Step 7: Next action
        Write-Host ""
        Show-Menu -Title "What would you like to do next?" -Options @(
            "Analyze another copilot",
            "Return to main menu",
            "Exit Navigator"
        ) -Icon "➡️"

        $nextChoice = Get-MenuSelection -MaxOption 3 -Prompt "Select next action"

        switch ($nextChoice) {
            1 { Start-AnalysisWorkflow }
            2 { Start-MainMenu }
            3 {
                Write-Host ""
                Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
                Write-Host "║  🧭  Navigator - Mission Complete  🧭                            ║" -ForegroundColor Cyan
                Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
                Write-Host ""
                exit 0
            }
            0 { Start-MainMenu }
        }

    } catch {
        Write-Error "Analysis failed: $($_.Exception.Message)"
        Write-Host ""
        Write-Host "Error details:" -ForegroundColor Red
        Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
        Write-Host ""

        Show-Menu -Title "What would you like to do?" -Options @(
            "Try again",
            "Return to main menu",
            "Exit"
        )

        $errorChoice = Get-MenuSelection -MaxOption 3 -Prompt "Select option"
        switch ($errorChoice) {
            1 { Start-AnalysisWorkflow }
            2 { Start-MainMenu }
            3 { exit 1 }
            0 { Start-MainMenu }
        }
    }
}

function Start-MainMenu {
    <#
    .SYNOPSIS
        Main menu for Navigator operations
    #>

    Show-Banner

    # Check authentication
    if (-not (Test-AzureCLI)) {
        Write-Warning "Please authenticate with Azure CLI first"
        Write-Info "Run: az login"
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return
    }

    Show-SectionHeader -Title "Main Operations" -Icon "🧭"

    Show-Menu -Title "What would you like to do?" -Options @(
        "Migrate Copilot - Move copilot between environments",
        "Analyze Copilot - Generate comprehensive analysis report",
        "Exit Navigator"
    ) -Icon "▶"

    $mainChoice = Get-MenuSelection -MaxOption 3 -Prompt "Select operation"

    switch ($mainChoice) {
        1 { Start-MigrationWorkflow }
        2 { Start-AnalysisWorkflow }
        3 {
            Write-Host ""
            Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
            Write-Host "║  🧭  Navigator - Journey Complete  🧭                            ║" -ForegroundColor Cyan
            Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
            Write-Host ""
            exit 0
        }
        0 {
            Write-Host ""
            Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
            Write-Host "║  🧭  Navigator - Journey Complete  🧭                            ║" -ForegroundColor Cyan
            Write-Host "╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
            Write-Host ""
            exit 0
        }
    }
}

#endregion

# Main execution
try {
    Start-MainMenu
}
catch {
    Write-Error "An unexpected error occurred: $_"
    Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray
}
finally {
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}