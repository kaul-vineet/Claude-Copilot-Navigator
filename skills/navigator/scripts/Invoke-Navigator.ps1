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

function New-NavigatorSolution {
    <#
    .SYNOPSIS
        Creates a new solution for Navigator imports
    #>
    param(
        [string]$EnvironmentUrl,
        [string]$BotName
    )

    try {
        $dvToken = Get-AccessToken -Resource $EnvironmentUrl

        $headers = @{
            "Authorization" = "Bearer $dvToken"
            "Content-Type" = "application/json"
            "OData-MaxVersion" = "4.0"
            "OData-Version" = "4.0"
        }

        # Generate solution name (must be unique and follow naming rules)
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $safeBotName = $BotName -replace '[^a-zA-Z0-9]', '' # Remove special chars
        $uniqueName = "Navigator_$($safeBotName)_$timestamp"
        $displayName = "Navigator Import: $BotName ($timestamp)"

        Write-Info "Creating solution: $displayName"

        # Get publisher (use default publisher)
        $publisherUri = "$EnvironmentUrl/api/data/v9.2/publishers?`$filter=isreadonly eq false&`$orderby=createdon asc&`$top=1"
        $publisher = Invoke-RestMethod -Uri $publisherUri -Headers $headers -Method Get

        if ($publisher.value.Count -eq 0) {
            Write-Error "No publisher found in target environment"
            return $null
        }

        $publisherId = $publisher.value[0].publisherid

        # Create solution
        $solutionData = @{
            uniquename = $uniqueName
            friendlyname = $displayName
            version = "1.0.0.0"
            description = "Created by Navigator for copilot import on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            "publisherid@odata.bind" = "/publishers($publisherId)"
        }

        $uri = "$EnvironmentUrl/api/data/v9.2/solutions"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($solutionData | ConvertTo-Json)

        Write-Success "Solution created: $uniqueName"

        # Get the solution ID
        $getSolutionUri = "$EnvironmentUrl/api/data/v9.2/solutions?`$filter=uniquename eq '$uniqueName'&`$select=solutionid,uniquename,friendlyname"
        $solution = Invoke-RestMethod -Uri $getSolutionUri -Headers $headers -Method Get

        return @{
            SolutionId = $solution.value[0].solutionid
            UniqueName = $uniqueName
            FriendlyName = $displayName
        }
    }
    catch {
        Write-Error "Failed to create solution: $_"
        return $null
    }
}

function Add-BotToSolution {
    <#
    .SYNOPSIS
        Adds a bot to a solution
    #>
    param(
        [string]$EnvironmentUrl,
        [string]$SolutionId,
        [string]$BotId,
        [int]$ComponentType = 101  # Bot component type
    )

    try {
        $dvToken = Get-AccessToken -Resource $EnvironmentUrl

        $headers = @{
            "Authorization" = "Bearer $dvToken"
            "Content-Type" = "application/json"
            "OData-MaxVersion" = "4.0"
            "OData-Version" = "4.0"
        }

        Write-Info "Adding bot to solution..."

        # Add solution component
        $addComponentData = @{
            ComponentId = $BotId
            ComponentType = $ComponentType
            SolutionUniqueName = ""
            AddRequiredComponents = $true
            DoNotIncludeSubcomponents = $false
        }

        $uri = "$EnvironmentUrl/api/data/v9.2/solutions($SolutionId)/Microsoft.Dynamics.CRM.AddSolutionComponent"
        Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($addComponentData | ConvertTo-Json) | Out-Null

        Write-Success "Bot added to solution"
        return $true
    }
    catch {
        Write-Warning "Failed to add bot to solution: $_"
        Write-Info "Bot was created but is in Default Solution"
        return $false
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

function New-NavigatorSolution {
    param(
        [string]$EnvironmentUrl,
        [string]$BotName
    )

    try {
        $dvToken = Get-AccessToken -Resource $EnvironmentUrl

        $headers = @{
            "Authorization" = "Bearer $dvToken"
            "Content-Type" = "application/json"
            "OData-MaxVersion" = "4.0"
            "OData-Version" = "4.0"
        }

        # Create unique solution name with timestamp
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $safeBotName = $BotName -replace '[^a-zA-Z0-9]', ''
        $uniqueName = "Navigator_$($safeBotName)_$($timestamp)_Navigator"
        $displayName = "$BotName - Navigator ($timestamp)"

        # Get first non-readonly publisher
        $publisherUri = "$EnvironmentUrl/api/data/v9.2/publishers?`$filter=isreadonly eq false&`$top=1"
        $publisherResponse = Invoke-RestMethod -Uri $publisherUri -Headers $headers -Method Get

        if ($publisherResponse.value.Count -eq 0) {
            Write-Warning "No writable publisher found"
            return $null
        }

        $publisherId = $publisherResponse.value[0].publisherid

        # Create solution
        $solutionData = @{
            uniquename = $uniqueName
            friendlyname = $displayName
            version = "1.0.0.0"
            "publisherid@odata.bind" = "/publishers($publisherId)"
        }

        $uri = "$EnvironmentUrl/api/data/v9.2/solutions"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($solutionData | ConvertTo-Json)

        $solutionId = $response.solutionid

        Write-Info "Created solution: $displayName"

        return @{
            SolutionId = $solutionId
            UniqueName = $uniqueName
            DisplayName = $displayName
        }
    }
    catch {
        Write-Warning "Failed to create solution: $_"
        return $null
    }
}

function Add-BotToSolution {
    param(
        [string]$EnvironmentUrl,
        [string]$SolutionId,
        [string]$BotId
    )

    try {
        $dvToken = Get-AccessToken -Resource $EnvironmentUrl

        $headers = @{
            "Authorization" = "Bearer $dvToken"
            "Content-Type" = "application/json"
            "OData-MaxVersion" = "4.0"
            "OData-Version" = "4.0"
        }

        # Add bot component to solution
        $addComponentData = @{
            ComponentId = $BotId
            ComponentType = 101  # Bot component type in Dataverse
            AddRequiredComponents = $true
        }

        $uri = "$EnvironmentUrl/api/data/v9.2/solutions($SolutionId)/Microsoft.Dynamics.CRM.AddSolutionComponent"
        Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($addComponentData | ConvertTo-Json)

        Write-Info "Added bot to solution"
        return $true
    }
    catch {
        Write-Warning "Failed to add bot to solution: $_"
        return $false
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

        # Step 1: Create new solution
        Show-Progress -Activity "Importing Bot" -Status "Creating solution..." -PercentComplete 20

        $botName = if ($Parameters -and $Parameters.name) { $Parameters.name } else { $exportData.Bot.name }
        $solution = New-NavigatorSolution -EnvironmentUrl $EnvironmentUrl -BotName $botName

        if (-not $solution) {
            Write-Warning "Solution creation failed. Bot will be imported to Default Solution."
        }

        Show-Progress -Activity "Importing Bot" -Status "Preparing bot definition..." -PercentComplete 30

        # Apply parameter changes
        $botData = $exportData.Bot | ConvertTo-Json -Depth 10 | ConvertFrom-Json

        foreach ($key in $Parameters.Keys) {
            if ($botData.PSObject.Properties.Name -contains $key) {
                $botData.$key = $Parameters[$key]
            }
        }

        # Remove system fields and entity references
        $botData.PSObject.Properties.Remove('botid')
        $botData.PSObject.Properties.Remove('createdon')
        $botData.PSObject.Properties.Remove('modifiedon')
        $botData.PSObject.Properties.Remove('_createdby_value')
        $botData.PSObject.Properties.Remove('_modifiedby_value')
        $botData.PSObject.Properties.Remove('_ownerid_value')
        $botData.PSObject.Properties.Remove('ownerid')
        $botData.PSObject.Properties.Remove('owningbusinessunit')
        $botData.PSObject.Properties.Remove('_owningbusinessunit_value')
        $botData.PSObject.Properties.Remove('owninguser')
        $botData.PSObject.Properties.Remove('_owninguser_value')
        $botData.PSObject.Properties.Remove('owningteam')
        $botData.PSObject.Properties.Remove('_owningteam_value')
        $botData.PSObject.Properties.Remove('_environmentvariabledefinitionid_value')
        $botData.PSObject.Properties.Remove('environmentvariabledefinitionid')
        $botData.PSObject.Properties.Remove('versionnumber')
        $botData.PSObject.Properties.Remove('overriddencreatedon')

        Show-Progress -Activity "Importing Bot" -Status "Creating bot..." -PercentComplete 50

        # Add solution context to headers if solution was created
        if ($solution) {
            $headers["MSCRM.SolutionUniqueName"] = $solution.UniqueName
            Write-Info "Creating bot in solution: $($solution.DisplayName)"
        }

        # Create bot (will be created in solution context if header is set)
        $uri = "$EnvironmentUrl/api/data/v9.2/bots"
        $newBot = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($botData | ConvertTo-Json -Depth 10)

        $newBotId = $newBot.botid

        if ($solution) {
            Write-Success "Bot created in solution: $($solution.DisplayName)"
        }

        if (-not $exportData.IsTemplate) {
            Show-Progress -Activity "Importing Bot" -Status "Importing components..." -PercentComplete 70

            # Collect all components to import
            $allComponents = @()
            if ($exportData.Components.Topics) { $allComponents += $exportData.Components.Topics }
            if ($exportData.Components.Triggers) { $allComponents += $exportData.Components.Triggers }
            if ($exportData.Components.Skills) { $allComponents += $exportData.Components.Skills }

            $componentCount = 0
            $totalComponents = $allComponents.Count
            $failedComponents = @()

            foreach ($component in $allComponents) {
                try {
                    $componentData = $component | ConvertTo-Json -Depth 10 | ConvertFrom-Json

                    # Remove ALL system and entity reference fields
                    $componentData.PSObject.Properties.Remove('botcomponentid')
                    $componentData.PSObject.Properties.Remove('_parentbotid_value')
                    $componentData.PSObject.Properties.Remove('parentbotid')  # Remove direct entity reference
                    $componentData.PSObject.Properties.Remove('createdon')
                    $componentData.PSObject.Properties.Remove('modifiedon')
                    $componentData.PSObject.Properties.Remove('_createdby_value')
                    $componentData.PSObject.Properties.Remove('_modifiedby_value')
                    $componentData.PSObject.Properties.Remove('_ownerid_value')

                    # Use OData navigation property for parent bot
                    $componentData | Add-Member -MemberType NoteProperty -Name "parentbotid@odata.bind" -Value "/bots($newBotId)" -Force

                    $uri = "$EnvironmentUrl/api/data/v9.2/botcomponents"
                    $null = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body ($componentData | ConvertTo-Json -Depth 10)

                    $componentCount++
                }
                catch {
                    # Component import failed - track it but continue with others
                    $componentName = if ($componentData.name) { $componentData.name } else { "Unknown" }
                    $componentType = switch ($componentData.componenttype) {
                        0 { "Topic" }
                        1 { "Trigger" }
                        2 { "Skill" }
                        default { "Component" }
                    }

                    $failedComponents += @{
                        Name = $componentName
                        Type = $componentType
                        Error = $_.Exception.Message
                    }

                    $componentCount++
                }

                $progress = 70 + ([Math]::Floor(($componentCount / $totalComponents) * 20))
                Show-Progress -Activity "Importing Bot" -Status "Importing component $componentCount of $totalComponents..." -PercentComplete $progress
            }

            # Report failed components if any
            if ($failedComponents.Count -gt 0) {
                Write-Host ""
                Write-Warning "$($failedComponents.Count) component(s) failed to import and require manual review:"
                Write-Host ""
                foreach ($failed in $failedComponents) {
                    Write-Host "  ⚠️  $($failed.Type): $($failed.Name)" -ForegroundColor Yellow
                }
                Write-Host ""
                Write-Host "  📝 Common Issues:" -ForegroundColor Cyan
                Write-Host "     • Tools/Actions with missing connections (APIs, Power Automate)" -ForegroundColor White
                Write-Host "     • Skills requiring authentication or external dependencies" -ForegroundColor White
                Write-Host "     • Topics referencing environment-specific variables" -ForegroundColor White
                Write-Host "     • Components with unsupported features in target environment" -ForegroundColor White
                Write-Host ""
                Write-Host "  🔧 Resolution:" -ForegroundColor Cyan
                Write-Host "     1. Open the bot in Copilot Studio" -ForegroundColor White
                Write-Host "     2. Review and reconfigure the listed components" -ForegroundColor White
                Write-Host "     3. Update connections, variables, and dependencies" -ForegroundColor White
                Write-Host "     4. Test each component individually" -ForegroundColor White
                Write-Host ""
            }
        }

        Show-Progress -Activity "Importing Bot" -Status "Publishing bot..." -PercentComplete 95

        # Publish bot using PvaPublish action
        try {
            $publishUri = "$EnvironmentUrl/api/data/v9.2/bots($newBotId)/Microsoft.Dynamics.CRM.PvaPublish"
            $null = Invoke-RestMethod -Uri $publishUri -Headers $headers -Method Post -Body "{}"
            Write-Success "Bot published successfully"
        }
        catch {
            Write-Warning "Auto-publish failed. Manual publish required."
            Write-Host ""
            Write-Host "  📝 Next Steps:" -ForegroundColor Yellow
            Write-Host "     1. Open Copilot Studio" -ForegroundColor White
            Write-Host "     2. Cross-check bot configurations (topics, triggers, variables)" -ForegroundColor White
            Write-Host "     3. Verify all connections (APIs, Power Automate, skills)" -ForegroundColor White
            Write-Host "     4. Test the bot in the Test panel" -ForegroundColor White
            Write-Host "     5. Publish from the UI once verified" -ForegroundColor White
            Write-Host ""
        }

        Show-Progress -Activity "Importing Bot" -Status "Complete!" -PercentComplete 100
        Write-Host ""

        if ($failedComponents.Count -gt 0) {
            Write-Host "✅ Bot imported with warnings!" -ForegroundColor Yellow
            Write-Info "New Bot ID: $newBotId"
            if ($solution) {
                Write-Info "Solution: $($solution.UniqueName)"
            }
            Write-Host ""
            Write-Warning "⚠️  $($failedComponents.Count) component(s) require manual review (see details above)"
            Write-Info "Review and reconfigure the failed components in Copilot Studio before publishing."
        }
        else {
            Write-Success "Bot imported successfully!"
            Write-Info "New Bot ID: $newBotId"
            if ($solution) {
                Write-Info "Solution: $($solution.UniqueName)"
            }
            Write-Info "All components imported successfully"
        }

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
        # Use the existing export function (already tested and working!)
        Write-Info "Exporting copilot for analysis..."
        $exportFile = Export-BotDefinition `
            -EnvironmentUrl $envUrl `
            -BotId $selectedBot.botid `
            -BotName $selectedBot.name `
            -TemplateOnly $false

        if (-not $exportFile) {
            Write-Error "Failed to export copilot data"
            return
        }

        # Read the export file
        $exportData = Get-Content -Path $exportFile -Raw | ConvertFrom-Json

        # Add size information
        $exportData | Add-Member -MemberType NoteProperty -Name "_exportSize" -Value (Get-Item $exportFile).Length -Force

        Write-Success "Data exported successfully"
        Write-Info "Export file: $exportFile"

        # Step 5: Perform analysis
        Write-Info "Analyzing copilot structure..."
        Write-Host ""

        # Import analysis module
        $modulePath = Join-Path $PSScriptRoot "Copilot-Analysis.psm1"
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