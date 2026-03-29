#Requires -Version 7.0

<#
.SYNOPSIS
    Quick Deploy module for rapid copilot testing

.DESCRIPTION
    Deploys copilots directly to target environment without solution packaging
    Fast, simple, ideal for testing and iteration
    NO SOLUTION CREATION - Direct deployment only
#>

function Invoke-QuickDeploy {
    <#
    .SYNOPSIS
        Quick deploy copilot to test environment (no solution)

    .DESCRIPTION
        Deploys copilot directly to target environment without creating solutions
        Perfect for rapid testing and iteration

    .PARAMETER BotName
        Name of copilot to deploy

    .PARAMETER SourceEnvironment
        Source environment (default: Development)

    .PARAMETER TargetEnvironment
        Target environment

    .PARAMETER OpenTestChat
        Open test chat in browser after deployment

    .EXAMPLE
        Invoke-QuickDeploy -BotName "Sales Assistant" -TargetEnvironment "UAT"

    .EXAMPLE
        Invoke-QuickDeploy -BotName "Support Bot" -SourceEnvironment "Dev" -TargetEnvironment "Test" -OpenTestChat
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$BotName,

        [Parameter(Mandatory=$false)]
        [string]$SourceEnvironment = "Development",

        [Parameter(Mandatory=$true)]
        [string]$TargetEnvironment,

        [switch]$OpenTestChat
    )

    $startTime = Get-Date

    try {
        Write-Host ""

        # Step 1: Get copilot definition from source
        Write-StepProgress "[1/3]" "Getting copilot from $SourceEnvironment..."
        $definition = Get-CopilotDefinition -Name $BotName -Environment $SourceEnvironment
        Write-Host "  ✅ Retrieved $($definition.Components.All.Count) components" -ForegroundColor Green

        # Step 2: Deploy directly (NO SOLUTION)
        Write-StepProgress "[2/3]" "Deploying to $TargetEnvironment..."
        $result = Deploy-CopilotDirect `
            -Definition $definition `
            -TargetEnvironment $TargetEnvironment
        Write-Host "  ✅ $($result.Action) copilot in $TargetEnvironment" -ForegroundColor Green

        # Step 3: Publish
        Write-StepProgress "[3/3]" "Publishing copilot..."
        Publish-Copilot -BotId $result.BotId -Environment $TargetEnvironment
        Write-Host "  ✅ Published successfully" -ForegroundColor Green

        $duration = (Get-Date) - $startTime
        $testUrl = Get-TestChatUrl -BotId $result.BotId -Environment $TargetEnvironment

        if ($OpenTestChat) {
            Start-Process $testUrl
        }

        return @{
            Success = $true
            BotId = $result.BotId
            Action = $result.Action
            TestUrl = $testUrl
            Duration = "$([Math]::Round($duration.TotalSeconds))s"
        }
    }
    catch {
        Write-Error "Quick deploy failed: $_"
        throw
    }
}

function Deploy-CopilotDirect {
    <#
    .SYNOPSIS
        Deploy copilot directly without solution packaging
    #>
    param(
        [Parameter(Mandatory=$true)]
        [object]$Definition,

        [Parameter(Mandatory=$true)]
        [string]$TargetEnvironment
    )

    try {
        # Check if copilot exists in target
        $existing = Find-CopilotByName -Name $Definition.Bot.name -Environment $TargetEnvironment

        if ($existing) {
            # Update existing copilot
            Write-Verbose "Updating existing copilot: $($existing.botid)"

            Update-CopilotInPlace `
                -BotId $existing.botid `
                -Definition $Definition `
                -Environment $TargetEnvironment

            return @{
                BotId = $existing.botid
                Action = "Updated"
            }
        }
        else {
            # Create new copilot
            Write-Verbose "Creating new copilot"

            $newBot = New-CopilotDirect `
                -Definition $Definition `
                -Environment $TargetEnvironment

            return @{
                BotId = $newBot.botid
                Action = "Created"
            }
        }
    }
    catch {
        Write-Error "Failed to deploy copilot: $_"
        throw
    }
}

function Find-CopilotByName {
    <#
    .SYNOPSIS
        Find copilot by name in environment
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$Environment
    )

    try {
        $envUrl = Get-EnvironmentUrl -Environment $Environment
        $headers = Get-AuthHeaders -Resource $envUrl

        $uri = "$envUrl/api/data/v9.2/bots"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        return $response.value | Where-Object { $_.name -eq $Name } | Select-Object -First 1
    }
    catch {
        # Return null if not found
        return $null
    }
}

function Update-CopilotInPlace {
    <#
    .SYNOPSIS
        Update existing copilot in place
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$BotId,

        [Parameter(Mandatory=$true)]
        [object]$Definition,

        [Parameter(Mandatory=$true)]
        [string]$Environment
    )

    try {
        $envUrl = Get-EnvironmentUrl -Environment $Environment
        $headers = Get-AuthHeaders -Resource $envUrl

        # Update bot properties
        $botData = $Definition.Bot | ConvertTo-Json -Depth 10 | ConvertFrom-Json
        $botData = Remove-SystemFields -Data $botData

        $uri = "$envUrl/api/data/v9.2/bots($BotId)"
        Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body ($botData | ConvertTo-Json -Depth 10) | Out-Null

        # Update components
        Update-BotComponents -BotId $BotId -Components $Definition.Components -Environment $Environment
    }
    catch {
        Write-Error "Failed to update copilot: $_"
        throw
    }
}

function New-CopilotDirect {
    <#
    .SYNOPSIS
        Create new copilot directly
    #>
    param(
        [Parameter(Mandatory=$true)]
        [object]$Definition,

        [Parameter(Mandatory=$true)]
        [string]$Environment
    )

    try {
        $envUrl = Get-EnvironmentUrl -Environment $Environment
        $headers = Get-AuthHeaders -Resource $envUrl
        $headers['Prefer'] = 'return=representation'

        # Create bot
        $botData = $Definition.Bot | ConvertTo-Json -Depth 10 | ConvertFrom-Json
        $botData = Remove-SystemFields -Data $botData

        $uri = "$envUrl/api/data/v9.2/bots"
        $newBot = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body ($botData | ConvertTo-Json -Depth 10)

        # Create components
        if ($Definition.Components) {
            New-BotComponents -BotId $newBot.botid -Components $Definition.Components -Environment $Environment
        }

        return $newBot
    }
    catch {
        Write-Error "Failed to create copilot: $_"
        throw
    }
}

function Update-BotComponents {
    <#
    .SYNOPSIS
        Update bot components
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$BotId,

        [Parameter(Mandatory=$true)]
        [object]$Components,

        [Parameter(Mandatory=$true)]
        [string]$Environment
    )

    try {
        $envUrl = Get-EnvironmentUrl -Environment $Environment
        $headers = Get-AuthHeaders -Resource $envUrl

        $allComponents = @($Components.All)

        foreach ($component in $allComponents) {
            try {
                # Check if component exists
                $uri = "$envUrl/api/data/v9.2/botcomponents?`$filter=_parentbotid_value eq $BotId and name eq '$($component.name)'"
                $existing = (Invoke-RestMethod -Uri $uri -Headers $headers -Method Get).value | Select-Object -First 1

                # Clean component data
                $compData = $component | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $compData = Remove-SystemFields -Data $compData
                $compData | Add-Member -Name "parentbotid@odata.bind" -Value "/bots($BotId)" -MemberType NoteProperty -Force

                if ($existing) {
                    # Update existing component
                    $uri = "$envUrl/api/data/v9.2/botcomponents($($existing.botcomponentid))"
                    Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body ($compData | ConvertTo-Json -Depth 10) | Out-Null
                }
                else {
                    # Create new component
                    $uri = "$envUrl/api/data/v9.2/botcomponents"
                    Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body ($compData | ConvertTo-Json -Depth 10) | Out-Null
                }
            }
            catch {
                Write-Warning "Failed to update component '$($component.name)': $_"
            }
        }
    }
    catch {
        Write-Error "Failed to update components: $_"
        throw
    }
}

function New-BotComponents {
    <#
    .SYNOPSIS
        Create bot components
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$BotId,

        [Parameter(Mandatory=$true)]
        [object]$Components,

        [Parameter(Mandatory=$true)]
        [string]$Environment
    )

    try {
        $envUrl = Get-EnvironmentUrl -Environment $Environment
        $headers = Get-AuthHeaders -Resource $envUrl

        $allComponents = @($Components.All)

        foreach ($component in $allComponents) {
            try {
                # Clean component data
                $compData = $component | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                $compData = Remove-SystemFields -Data $compData
                $compData | Add-Member -Name "parentbotid@odata.bind" -Value "/bots($BotId)" -MemberType NoteProperty -Force

                # Create component
                $uri = "$envUrl/api/data/v9.2/botcomponents"
                Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body ($compData | ConvertTo-Json -Depth 10) | Out-Null
            }
            catch {
                Write-Warning "Failed to create component '$($component.name)': $_"
            }
        }
    }
    catch {
        Write-Error "Failed to create components: $_"
        throw
    }
}

# Export functions
Export-ModuleMember -Function @(
    'Invoke-QuickDeploy'
)
