# 🧭 Navigator - Copilot Migration Pathfinder

> *"Every journey begins with a single step"* - Lao Tzu

**Guides Microsoft Copilot Studio copilots through migrations between Power Platform environments with precision and clarity**

![Version](https://img.shields.io/badge/version-1.1.0-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Installation](#-installation)
- [Usage](#-usage)
- [Copilot Analysis](#-copilot-analysis)
- [How It Works](#-how-it-works)
- [Distribution](#-distribution--sharing)
- [Troubleshooting](#-troubleshooting)
- [Advanced](#-advanced-usage)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Overview

**Navigator** is a powerful, enterprise-ready tool that guides Microsoft Copilot Studio copilots and templates through migrations between Power Platform environments. Like a skilled pathfinder, Navigator charts the course for successful copilot journeys.

### Why Navigator?

- ✅ **No Manual Work** - Automated migration of copilots and all components
- ✅ **Comprehensive Analysis** - Understand copilot structure before migrating
- ✅ **Safe & Validated** - Prevents invalid configurations (same source/target)
- ✅ **Beautiful UI** - Interactive menus in both CLI and Claude Code
- ✅ **Enterprise Ready** - Azure AD authentication, audit trails, error handling
- ✅ **Flexible** - Migrate templates or full copilots with all content

### Use Cases

- 🔄 **Environment Promotion** - Move copilots from Dev → Test → Prod
- 🔍 **Copilot Discovery** - Analyze structure, complexity, and quality
- 📦 **Template Distribution** - Share copilot structures across teams
- 🏢 **Multi-Tenant Deployment** - Deploy same copilot to multiple orgs
- 🔧 **Backup & Restore** - Export copilots for safekeeping
- 🚀 **CI/CD Integration** - Automate deployments in pipelines
- 📊 **Documentation** - Auto-generate copilot documentation

---

## ✨ Features

### Core Capabilities

| Feature | Description |
|---------|-------------|
| 🧭 **Main Menu** | Choose between Migration or Analysis operations |
| 🔍 **Copilot Analysis** | ⭐ NEW - Comprehensive structure, complexity, and quality analysis |
| 🎯 **Environment Selection** | Interactive menu to choose source and target environments |
| 🤖 **Copilot Discovery** | Automatically lists all copilots with metadata |
| 🔄 **Migration Types** | Template-only or full migration with all components |
| ⚙️ **Parameter Customization** | Change names, descriptions, languages during migration |
| 📊 **Progress Tracking** | Real-time progress bars and status updates |
| ✅ **Validation** | Prevents errors (source = target, missing permissions) |
| 📋 **Audit Reports** | Detailed logs of all migrations and analyses |
| 🔐 **Secure** | Uses Azure CLI authentication (no stored credentials) |

### NEW: Analysis Features (v1.1.0)

| Analysis | What You Get |
|----------|--------------|
| 📊 **Structure Analysis** | Topics (custom vs system), skills, knowledge sources, components |
| 🎯 **Complexity Scoring** | 0-10 scale with breakdown (topics, logic, integrations, size) |
| ⭐ **Quality Assessment** | Good practices, improvement suggestions, issue detection |
| 🚀 **Migration Readiness** | Time estimate, difficulty level, component count |
| 📝 **Summary Generation** | Human-readable description of copilot purpose |
| 💾 **Export Options** | Save analysis as Markdown (.md) or JSON (.json) |
| 💰 **Zero Cost** | No external API calls - all analysis runs locally |

### User Interface

**Two modes available:**

1. **Claude Code Skill** - Conversational, guided workflow in Claude chat
2. **PowerShell Script** - Traditional CLI with beautiful ASCII UI

Both feature:
- Color-coded messages (Info, Success, Warning, Error)
- Box-drawing characters and emoji icons
- Tabular data display
- Interactive menus
- Progress indicators
- Continuous operation (return to menu after tasks)

---

## 🚀 Installation

### Prerequisites

Before installing, ensure you have:

- ✅ **PowerShell 7.0+** - [Download](https://aka.ms/powershell)
- ✅ **Azure CLI** - [Download](https://aka.ms/installazurecli)
- ✅ **Power Platform Access** - Admin or appropriate permissions
- ✅ **Internet Connection** - For API calls to Power Platform

**Check your setup:**
```powershell
# Check PowerShell version (should be 7.0+)
$PSVersionTable.PSVersion

# Check Azure CLI
az --version

# Login to Azure
az login
```

### Installation Methods

#### Method 1: Install as Claude Code Skill (Recommended)

**For use with `/navigator` command in Claude Code:**

```powershell
# Navigate to the navigator directory
cd path\to\copilot-zapper

# Run the installer
.\install-skill.ps1

# Restart Claude Code
# Then type: /navigator
```

**What this does:**
- ✅ Copies skill files to `~/.claude/skills/navigator/`
- ✅ Registers `/navigator` command in Claude Code
- ✅ Includes all helper scripts and modules
- ✅ Ready to use after Claude Code restart

**Management commands:**
```powershell
# Update to latest version
.\install-skill.ps1 -Update

# Uninstall the skill
.\install-skill.ps1 -Uninstall
```

#### Method 2: Use PowerShell Scripts Directly

**For standalone usage without Claude Code:**

```powershell
# Clone or download the repository
git clone <your-repo-url>
cd copilot-zapper

# Authenticate with Azure
az login

# Run Navigator
.\Start-Navigator.ps1
```

**No installation needed** - scripts run directly from the folder.

#### Method 3: Quick Install from ZIP

1. **Extract the ZIP** to your desired location
2. **Open PowerShell 7** in that directory
3. **Run:** `.\install-skill.ps1`
4. **Restart Claude Code**

---

## 💡 Usage

### Using as a Claude Code Skill

**Simplest method - conversational and interactive:**

1. **Open Claude Code**
2. **Type:** `/navigator`
3. **Choose operation:**

```
╔══════════════════════════════════════════════════════════════════╗
║          🧭  NAVIGATOR - COPILOT MIGRATION PATHFINDER  🧭        ║
║       'Every journey begins with a single step' - Lao Tzu       ║
╚══════════════════════════════════════════════════════════════════╝

✅ Authenticated as: admin@company.com

What would you like to do?
  [1] ▶ Migrate Copilot - Move copilot between environments
  [2] ▶ Analyze Copilot - Generate comprehensive analysis report
  [3] ▶ Exit Navigator
```

**Migration workflow:**
1. Select source environment
2. Choose copilot to migrate
3. Pick migration type (Template or Full)
4. Customize parameters (optional)
5. Select target environment
6. Review and confirm
7. Watch the migration execute
8. Get completion report

**Analysis workflow:**
1. Select environment
2. Choose copilot to analyze
3. View comprehensive analysis report
4. Export as Markdown or JSON (optional)
5. Choose next action

### Using PowerShell Scripts Directly

**For automation, scripting, or when Claude Code isn't available:**

Navigator can run as standalone PowerShell scripts without installing as a Claude Code skill. This is perfect for:
- Teams without Claude Code
- Automation and CI/CD pipelines
- Quick one-time migrations
- Testing and validation

---

#### **Quick Start: Run Scripts Directly**

**Step 1: Open PowerShell 7**
```powershell
# Make sure you're using PowerShell 7, not Windows PowerShell 5.1
$PSVersionTable.PSVersion  # Should be 7.0 or higher
```

**Step 2: Navigate to Navigator**
```powershell
cd C:\code\copilot-zapper
```

**Step 3: Authenticate with Azure**
```powershell
# Login to Azure (one-time, or when token expires)
az login

# Verify you're logged in
az account show
```

**Step 4: Run Navigator**
```powershell
# Option 1: With prerequisite checks (recommended)
.\Start-Navigator.ps1

# Option 2: Direct execution (faster)
.\Invoke-Navigator.ps1

# Option 3: Test mode (no actual operations)
.\Demo-Navigator.ps1
```

---

#### **Option A: Interactive Launcher (Recommended for First Use)**

```powershell
.\Start-Navigator.ps1
```

**What it does:**
1. ✅ Checks PowerShell version (requires 7.0+)
2. ✅ Checks Azure CLI installation
3. ✅ Validates Azure authentication
4. ✅ Displays helpful error messages if issues found
5. ✅ Launches Invoke-Navigator.ps1 if all checks pass

**When to use:**
- First time running Navigator
- After system updates
- When troubleshooting issues
- When you want validation before execution

**Example output:**
```
╔══════════════════════════════════════════════════════════════════╗
║          🧭  NAVIGATOR - PREREQUISITE CHECKER  🧭                ║
╚══════════════════════════════════════════════════════════════════╝

✅ PowerShell 7.6.0 detected
✅ Azure CLI 2.84.0 detected
✅ Authenticated as: admin@company.com (tenant: contoso.com)

All prerequisites met. Launching Navigator...

╔══════════════════════════════════════════════════════════════════╗
║          🧭  NAVIGATOR - COPILOT MIGRATION PATHFINDER  🧭        ║
╚══════════════════════════════════════════════════════════════════╝

What would you like to do?
  [1] ▶ Migrate Copilot
  [2] ▶ Analyze Copilot
  [3] ▶ Exit Navigator

>
```

---

#### **Option B: Direct Execution (For Regular Use)**

```powershell
.\Invoke-Navigator.ps1
```

**What it does:**
- Launches Navigator immediately
- No prerequisite checks (assumes you're already set up)
- Slightly faster startup
- Same full functionality (Migration + Analysis)

**When to use:**
- After you've already verified prerequisites
- Regular daily use
- When you know your setup is correct
- For automation scripts

**Example:**
```powershell
# Quick daily use
PS C:\code\copilot-zapper> .\Invoke-Navigator.ps1

╔══════════════════════════════════════════════════════════════════╗
║          🧭  NAVIGATOR - COPILOT MIGRATION PATHFINDER  🧭        ║
╚══════════════════════════════════════════════════════════════════╝

What would you like to do?
  [1] ▶ Migrate Copilot
  [2] ▶ Analyze Copilot
  [3] ▶ Exit Navigator

> 1

✅ Authenticated as: admin@company.com
🔍 Fetching environments...
✅ Found 3 environments

Select Source Environment:
  [1] Development (org123)
  [2] Test (org456)
  [3] Production (org789)
  [0] Back/Cancel

> 1

✅ Source: Development
🔍 Fetching copilots...
✅ Found 5 copilots

[... continues with migration workflow ...]
```

---

#### **Option C: Demo Mode (Testing & Validation)**

```powershell
.\Demo-Navigator.ps1
```

**What it does:**
1. ✅ Validates prerequisites (PowerShell 7, Azure CLI)
2. ✅ Tests Azure authentication
3. ✅ Lists all accessible environments
4. ✅ Shows copilots in each environment
5. ❌ Does NOT perform any migrations or modifications
6. ✅ Safe to run anytime

**When to use:**
- First time setup testing
- After installing prerequisites
- Verifying permissions
- Troubleshooting connectivity
- Checking what copilots are available
- Before giving to a new team member

**Example output:**
```
╔══════════════════════════════════════════════════════════════════╗
║          🧭  NAVIGATOR - DEMO MODE  🧭                           ║
╚══════════════════════════════════════════════════════════════════╝

This is a non-interactive demo that validates your setup.
No actual migrations will be performed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 1: Prerequisites Check

✅ PowerShell 7.6.0
✅ Azure CLI 2.84.0
✅ Authenticated as: admin@company.com

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 2: Environment Discovery

🔍 Fetching environments...
✅ Found 3 environments:

  1. Development (org123.crm.dynamics.com)
  2. Test (org456.crm.dynamics.com)
  3. Production (org789.crm.dynamics.com)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 3: Copilot Discovery (Development)

🔍 Fetching copilots from Development...
✅ Found 5 copilots:

  1. Customer Service Bot (created: 2026-01-15)
  2. HR Assistant (created: 2026-02-01)
  3. IT Help Desk (created: 2026-02-15)
  4. Sales Assistant (created: 2026-03-01)
  5. Product Support (created: 2026-03-10)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Demo Complete!

Your setup is ready. You can now run:
  .\Start-Navigator.ps1  (with prerequisite checks)
  .\Invoke-Navigator.ps1 (direct execution)

Note: This was a read-only test. No changes were made.
```

---

#### **Complete Example: Migration via PowerShell**

Here's a full session from start to finish:

```powershell
# 1. Open PowerShell 7
# 2. Navigate to Navigator
PS> cd C:\code\copilot-zapper

# 3. Login to Azure (if not already)
PS> az login
# Browser opens, you authenticate, return to terminal

# 4. Verify authentication
PS> az account show
{
  "name": "Visual Studio Subscription",
  "user": {
    "name": "admin@company.com"
  }
}

# 5. Run Navigator
PS> .\Start-Navigator.ps1

╔══════════════════════════════════════════════════════════════════╗
║          🧭  NAVIGATOR - COPILOT MIGRATION PATHFINDER  🧭        ║
╚══════════════════════════════════════════════════════════════════╝

What would you like to do?
  [1] ▶ Migrate Copilot
  [2] ▶ Analyze Copilot
  [3] ▶ Exit Navigator

PS> 1

Select Source Environment:
  [1] Development
  [2] Test
  [3] Production

PS> 1

✅ Source: Development
📊 Found 5 copilots

Select Copilot:
  [1] Customer Service Bot
  [2] HR Assistant
  [3] IT Help Desk

PS> 1

✅ Selected: Customer Service Bot

Migration Type:
  [1] Template Only
  [2] Full Copilot

PS> 2

✅ Migration Type: Full Copilot

Customize Parameters:
  [1] Bot Name
  [2] Description
  [3] No changes

PS> 3

✅ Using default parameters

Select Target Environment:
  [1] Development
  [2] Test
  [3] Production

PS> 3

✅ Target: Production

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MIGRATION SUMMARY

Source: Development
Target: Production
Copilot: Customer Service Bot
Type: Full Copilot
Components: ~35 items

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proceed with migration? (Y/N): Y

🔄 Exporting copilot from Development...
[████████████████████████████████████████████] 100%
✅ Export complete (2.4 MB)

🔄 Creating copilot in Production...
✅ Bot created (ID: abc-123-def-456)

🔄 Importing 35 components...
[████████████████████████████████████████████] 100% (35/35)
✅ Components imported

🔄 Publishing copilot...
✅ Published successfully

╔══════════════════════════════════════════════════════════════════╗
║  🧭  Mission Accomplished - Navigator                            ║
╚══════════════════════════════════════════════════════════════════╝

✅ Migration completed successfully!
📊 New Bot ID: abc-123-def-456
📄 Report: migration-report-20260328-143045.txt

What would you like to do next?
  [1] ▶ Migrate another copilot
  [2] ▶ Return to main menu
  [3] ▶ Exit Navigator

PS> 3

Exiting Navigator. Press any key to exit...
```

---

#### **Troubleshooting Direct Script Usage**

**Error: "The term '.\Start-Navigator.ps1' is not recognized"**
```powershell
# Solution: Make sure you're in the correct directory
cd C:\code\copilot-zapper
ls *.ps1  # Should show all Navigator scripts
```

**Error: "Script is not digitally signed"**
```powershell
# Solution: Allow local scripts
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\Start-Navigator.ps1
```

**Error: "Azure CLI not found"**
```powershell
# Solution: Install Azure CLI
winget install -e --id Microsoft.AzureCLI
# Restart PowerShell after installation
```

**Error: "PowerShell version too old"**
```powershell
# Solution: Install PowerShell 7
winget install --id Microsoft.Powershell --source winget
# Close this window and open PowerShell 7 (not Windows PowerShell)
```

**Error: "Not authenticated with Azure"**
```powershell
# Solution: Login
az login

# Verify
az account show
```

---

#### **Running Scripts from Different Directory**

You can run Navigator from anywhere:

```powershell
# Option 1: Use full path
C:\code\copilot-zapper\Start-Navigator.ps1

# Option 2: Add to PATH (advanced)
$env:Path += ";C:\code\copilot-zapper"
Start-Navigator.ps1  # Now works from anywhere

# Option 3: Create alias (advanced)
Set-Alias navigator C:\code\copilot-zapper\Start-Navigator.ps1
navigator  # Easy!
```

---

#### **Automation Example**

For scheduled or automated migrations:

```powershell
# Example: Automated daily migration script
$ErrorActionPreference = "Stop"

# 1. Ensure authenticated
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Error "Not authenticated. Run 'az login' first."
    exit 1
}

# 2. Run Navigator
# Note: Current version is interactive only
# Future version will support unattended mode:
# .\Invoke-Navigator.ps1 -Unattended -ConfigFile "migration.json"

Write-Host "✅ Ready for migration"
```

### Example: Complete Migration Session

```powershell
# Step 1: Authenticate
PS> az login
# Browser opens, you sign in, return to terminal

# Step 2: Launch Navigator
PS> .\Start-Navigator.ps1

# Step 3: Follow the prompts
╔══════════════════════════════════════════════════════════════════╗
║          🧭  NAVIGATOR - COPILOT MIGRATION PATHFINDER  🧭        ║
╚══════════════════════════════════════════════════════════════════╝

✅ Authenticated as: admin@company.com

What would you like to do?
  [1] ▶ Migrate Copilot
  [2] ▶ Analyze Copilot
  [3] ▶ Exit Navigator

> 1

✅ Found 3 environments

Select Source Environment:
  [1] Development
  [2] Test
  [3] Production

> 1

✅ Source: Development
📊 Found 5 copilots

Select Copilot:
  [1] Customer Service Bot
  [2] HR Assistant
  [3] IT Help Desk

> 1

✅ Selected: Customer Service Bot

Migration Type:
  [1] Template Only
  [2] Full Copilot

> 2

✅ Migration Type: Full Copilot

Customize Parameters:
  [1] Bot Name
  [2] Description
  [3] No changes

> 1

New name: Customer Service Bot - Production

✅ Parameters set

Select Target Environment:
  [1] Development
  [2] Test
  [3] Production

> 3

✅ Target: Production

Review Migration:
  Source: Development
  Target: Production
  Copilot: Customer Service Bot
  New Name: Customer Service Bot - Production
  Type: Full Copilot

Proceed? (Y/N): Y

🔄 Exporting copilot...
[████████████████████████████████████████████] 100%

🔄 Importing to target...
[████████████████████████████████████████████] 100%

🔄 Publishing copilot...

╔══════════════════════════════════════════════════════════════════╗
║  🧭  Mission Accomplished - Navigator                            ║
╚══════════════════════════════════════════════════════════════════╝

✅ Migration completed successfully!
📊 New Bot ID: abc-123-def-456
📄 Report: migration-report-20260328-143045.txt

What would you like to do next?
  [1] ▶ Migrate another copilot
  [2] ▶ Return to main menu
  [3] ▶ Exit Navigator
```

### Example: Copilot Analysis Session

```powershell
PS> .\Start-Navigator.ps1

╔══════════════════════════════════════════════════════════════════╗
║          🧭  NAVIGATOR - COPILOT MIGRATION PATHFINDER  🧭        ║
╚══════════════════════════════════════════════════════════════════╝

What would you like to do?
  [1] ▶ Migrate Copilot
  [2] ▶ Analyze Copilot
  [3] ▶ Exit Navigator

> 2

Select Environment:
  [1] Development
  [2] Test
  [3] Production

> 1

Select Copilot:
  [1] Customer Service Bot
  [2] HR Assistant

> 1

🔄 Exporting copilot data for analysis...
✅ Data exported successfully
🔄 Analyzing copilot structure...

╔══════════════════════════════════════════════════════════════════╗
║              COPILOT ANALYSIS REPORT                             ║
╚══════════════════════════════════════════════════════════════════╝

🤖 Customer Service Bot
🆔 Bot ID: abc-123-def-456
📅 Created: 2026-01-15 | Modified: 2026-03-20
🌐 Language: English (1033)
📊 State: Active

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 SUMMARY

  This copilot handles topics including Order Status, Shipping Info,
  Returns. It integrates with 2 external system(s) and uses 1 knowledge source(s).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏗️ STRUCTURE

  Topics: 18 total
    • Custom: 6
    • System: 12

  Custom Topics:
    ✓ Order Status
      Check order status and tracking
    ✓ Shipping Info
      Shipping methods and times
    ✓ Returns
      Return policy and process

  Skills & Integrations: 2
    • Order API - Retrieves order information
    • Shipping Tracker - Real-time shipping updates

  Knowledge Sources: 1
    • Customer FAQ

  Total Components: 35
  Size: 2.4 MB

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 COMPLEXITY ANALYSIS

  Overall Score: 6.5/10 (Medium)

  Breakdown:
    Topics:       7.2/10
    Custom Logic: 6.0/10
    Integrations: 4.0/10
    Knowledge:    1.5/10
    Size:         4.9/10

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⭐ QUALITY ASSESSMENT

  Quality Score: 7.5/10 (Good)

  ✅ Good Practices (5):
     ✓ Has custom topics (not just defaults)
     ✓ Has error handling topic
     ✓ Has escalation path configured
     ✓ Integrates with external systems
     ✓ Uses knowledge sources for answers

  ⚠️ Suggested Improvements (2):
     ! Consider adding more knowledge sources
     ! Add more custom topics for specific scenarios

  ❌ Issues Found (0):
     None detected

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 MIGRATION READINESS

  Estimated Time: 4-5 minutes
  Difficulty: Medium
  Components to Migrate: 35

  Readiness: ✅ Ready for migration

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Report Generated: 2026-03-28 13:45:23
Analysis Engine: Navigator v1.1

Would you like to save this analysis?
  [1] Save as Markdown (.md)
  [2] Save as JSON (.json)
  [3] Don't save, just view

> 1

Enter output directory (press Enter for current directory):

✅ Analysis saved to: Customer_Service_Bot-Analysis-20260328-134523.md

What would you like to do next?
  [1] ▶ Analyze another copilot
  [2] ▶ Return to main menu
  [3] ▶ Exit Navigator
```

---

## 🔍 Copilot Analysis

### What Gets Analyzed

Navigator's analysis engine provides comprehensive insights into your copilots:

#### 1. **Structure Analysis**
- Total component count
- Custom vs system topics
- Skills and integrations
- Knowledge sources
- Overall size (MB/KB)

#### 2. **Complexity Scoring**
```
Overall Score: X/10 (Low/Medium/High)

Breakdown:
  Topics:       Score based on topic count
  Custom Logic: Score based on custom topic complexity
  Integrations: Score based on external connections
  Knowledge:    Score based on knowledge source count
  Size:         Score based on data size
```

**Complexity Levels:**
- **Low (0-3)**: Simple copilots, easy to migrate
- **Medium (3-6)**: Average complexity, standard migration
- **Medium-High (6-8)**: Complex copilots, needs care
- **High (8-10)**: Very complex, plan carefully

#### 3. **Quality Assessment**

**Good Practices Detected:**
- ✅ Has custom topics (not just defaults)
- ✅ Has error handling topic
- ✅ Has escalation path configured
- ✅ Integrates with external systems
- ✅ Uses knowledge sources
- ✅ Good topic organization

**Improvement Suggestions:**
- ⚠️ Add more custom topics for specific scenarios
- ⚠️ Consider adding integrations
- ⚠️ Split "General" topic into specific domains
- ⚠️ Add knowledge sources for better answers

**Issues Found:**
- ❌ Duplicate topic names
- ❌ Missing error handling
- ❌ Too many topics (maintenance burden)

#### 4. **Migration Readiness**

```
Estimated Time: X-Y minutes
Difficulty: Low/Medium/High
Component Count: N components
Status: ✅ Ready / ⚠️ Review needed / ❌ Fix issues first
```

#### 5. **Auto-Generated Summary**

Example: *"This copilot handles topics including Order Status, Shipping Info, Returns. It integrates with 2 external system(s) and uses 1 knowledge source(s)."*

### Export Formats

**Markdown (.md)** - Human-readable documentation
```markdown
# Customer Service Bot - Analysis Report

## Summary
This copilot handles...

## Structure
- Topics: 18 total
- Custom: 6
...
```

**JSON (.json)** - Machine-readable data
```json
{
  "Bot": {
    "Name": "Customer Service Bot",
    "BotId": "abc-123",
    ...
  },
  "Complexity": {
    "Overall": 6.5,
    "Breakdown": {...}
  },
  ...
}
```

### Use Cases for Analysis

| Scenario | How Analysis Helps |
|----------|-------------------|
| **Before Migration** | Understand what you're migrating, estimate time |
| **Documentation** | Auto-generate copilot documentation |
| **Inventory** | Catalog all copilots across environments |
| **Quality Review** | Identify issues before they impact users |
| **Onboarding** | Help new team members understand copilots |
| **Compliance** | Audit capabilities for governance |

---

## ⚙️ How It Works

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    USER INTERFACE                           │
│  • Claude Code Skill (/navigator)                          │
│  • PowerShell Scripts (.\Invoke-Navigator.ps1)             │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────┐
│              AUTHENTICATION                                 │
│  • Azure CLI (az login)                                    │
│  • OAuth 2.0 Bearer Tokens                                 │
│  • No Stored Credentials                                   │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────┐
│            POWER PLATFORM APIs                              │
│  • Business Application Platform (BAP)                     │
│  • Dataverse OData v9.2                                    │
│  • Bot Management APIs                                     │
└─────────────────┬───────────────────────────────────────────┘
                  │
        ┌─────────┴─────────┐
        ▼                   ▼
┌───────────────┐   ┌───────────────┐
│   MIGRATION   │   │   ANALYSIS    │
│    ENGINE     │   │    ENGINE     │
│               │   │               │
│ • Export bot  │   │ • Parse data  │
│ • Transform   │   │ • Score       │
│ • Import bot  │   │ • Assess      │
│ • Publish     │   │ • Report      │
└───────────────┘   └───────────────┘
```

### What Each Script Does

#### `install-skill.ps1` - Skill Installer

**Purpose:** Installs Navigator as a Claude Code skill

**What it does:**
1. Checks for Claude Code installation
2. Creates `~/.claude/skills/navigator/` directory
3. Copies skill definition and helper scripts
4. Registers `/navigator` command
5. Provides update and uninstall options

**Usage:**
```powershell
.\install-skill.ps1           # Install
.\install-skill.ps1 -Update   # Update to latest
.\install-skill.ps1 -Uninstall # Remove
```

#### `Start-Navigator.ps1` - Prerequisites Checker & Launcher

**Purpose:** Validates prerequisites and launches Navigator

**What it does:**
1. **Checks PowerShell version** (requires 7.0+)
2. **Checks Azure CLI** installation
3. **Validates authentication** (az account show)
4. **Launches main workflow** if all checks pass
5. **Provides helpful error messages** with fixes

**Example:**
```powershell
PS> .\Start-Navigator.ps1

✅ PowerShell 7.6.0 detected
✅ Azure CLI 2.84.0 detected
✅ Authenticated as: admin@company.com

Launching Navigator...
```

#### `Invoke-Navigator.ps1` - Main Engine

**Purpose:** Core migration and analysis engine

**Contains:**
- `Start-MainMenu()` - Main operation selector
- `Start-MigrationWorkflow()` - Migration process
- `Start-AnalysisWorkflow()` - Analysis process
- Helper functions for UI, API calls, data processing

**Functions:**
- Environment discovery
- Copilot listing
- Migration execution
- Analysis execution
- Report generation

**Size:** ~34KB (~1000 lines)

#### `Demo-Navigator.ps1` - Environment Validator

**Purpose:** Non-interactive validation script

**What it does:**
1. Checks prerequisites
2. Tests API connectivity
3. Lists environments (without prompts)
4. Shows available copilots
5. Doesn't perform actual migration or analysis

**Useful for:**
- Testing after installation
- Verifying permissions
- Troubleshooting connectivity

#### `Modules\Copilot-Analysis.psm1` - Analysis Module

**Purpose:** Copilot structure analysis engine

**Functions:**
- `Get-CopilotAnalysis` - Main analysis function
- `Show-CopilotAnalysisReport` - Console display
- `Export-CopilotAnalysisReport` - File export
- `Get-ComplexityScore` - Complexity calculator
- `Get-QualityAssessment` - Quality evaluator

**No external dependencies** - all analysis runs locally

**Size:** ~26KB (~635 lines)

#### `skills/navigator.md` - Claude Skill Definition

**Purpose:** Defines Navigator's behavior in Claude Code

**Contains:**
- Skill invocation instructions
- Personality and style guidelines
- Interactive workflow phases (1-15)
- API call specifications
- Error handling procedures

**Phases:**
1. Welcome & Authentication
2. Main Operation Selection
3-10. Migration Workflow
11-15. Analysis Workflow

### Data Flow

#### Migration Flow

```
1. EXPORT from Source
   GET /api/data/v9.2/bots({botId})
   GET /api/data/v9.2/botcomponents?$filter=_parentbotid_value eq {botId}
   ↓
2. TRANSFORM in Memory
   - Remove system fields (botid, createdon, etc.)
   - Apply parameter changes
   - Set OData navigation properties
   ↓
3. IMPORT to Target
   POST /api/data/v9.2/bots
   POST /api/data/v9.2/botcomponents (for each)
   ↓
4. PUBLISH
   POST /api/data/v9.2/bots({newBotId})/Microsoft.Dynamics.CRM.PublishBot
```

#### Analysis Flow

```
1. EXPORT Data
   Get bot definition + all components
   ↓
2. PARSE Structure
   Categorize: Topics (custom vs system), Skills, Knowledge
   ↓
3. ANALYZE
   Calculate: Complexity, Quality, Migration readiness
   ↓
4. REPORT
   Generate: Summary, scores, recommendations
   ↓
5. EXPORT (Optional)
   Save as: Markdown (.md) or JSON (.json)
```

### Security Model

**Authentication:**
- ✅ Uses Azure CLI OAuth 2.0
- ✅ No credentials stored in scripts
- ✅ Tokens expire automatically
- ✅ Supports MFA and Conditional Access

**Data Handling:**
- ✅ All processing in-memory
- ✅ Export files optional (user controlled)
- ✅ All API calls over HTTPS
- ✅ Follows Microsoft security best practices

**Permissions Required:**
- Power Platform Admin (or Environment Admin)
- Azure AD authentication
- Dataverse API access

---

## 📦 Distribution & Sharing

### Quick Distribution Methods

#### Option 1: Share as ZIP (Simplest)

**Create a distribution package:**

```powershell
# From the copilot-zapper directory
Compress-Archive -Path * -DestinationPath Navigator-v1.1.0.zip
```

**Recipients install:**
1. Extract ZIP to desired location
2. Open PowerShell 7 in that directory
3. Run: `.\install-skill.ps1`
4. Restart Claude Code

**Pros:**
- ✅ Easy to share (email, SharePoint, Teams)
- ✅ Self-contained
- ✅ Version control via filename

**Cons:**
- ⚠️ No automatic updates
- ⚠️ Manual distribution

#### Option 2: Share via Git (Best for Teams)

**Set up internal repository:**

```bash
# Create internal Git repo
git init
git add .
git commit -m "Navigator v1.1.0"
git remote add origin https://your-git-server/navigator.git
git push -u origin main
```

**Team members install:**

```powershell
git clone https://your-git-server/navigator.git
cd navigator
.\install-skill.ps1
```

**Update to latest:**

```powershell
cd navigator
git pull
.\install-skill.ps1 -Update
```

**Pros:**
- ✅ Easy updates (git pull)
- ✅ Version history
- ✅ Collaborative improvements

**Cons:**
- ⚠️ Requires Git infrastructure
- ⚠️ Team needs Git knowledge

#### Option 3: Internal Network Share

**Set up:**
1. Copy folder to network share: `\\fileserver\tools\Navigator\`
2. Set read permissions for team

**Users install:**

```powershell
# Map network drive (optional)
New-PSDrive -Name "T" -PSProvider FileSystem -Root "\\fileserver\tools"

# Navigate to Navigator
cd T:\Navigator

# Install
.\install-skill.ps1
```

**Pros:**
- ✅ Central distribution
- ✅ Easy access

**Cons:**
- ⚠️ Network dependency
- ⚠️ Manual updates

### Distribution Checklist

Before sharing Navigator, ensure:

- [ ] All scripts are present and working
- [ ] README.md is included
- [ ] LICENSE file is included
- [ ] No sensitive data (credentials, org names)
- [ ] Version number is updated in:
  - [ ] README.md badge
  - [ ] CHANGELOG.md
  - [ ] Script headers
- [ ] Test installation on clean machine
- [ ] Document any organization-specific configurations

### Package Contents

Essential files for distribution:

```
Navigator/
├── install-skill.ps1          # Installer
├── Start-Navigator.ps1        # Launcher
├── Invoke-Navigator.ps1       # Main engine
├── Demo-Navigator.ps1         # Validator
├── Modules/
│   └── Copilot-Analysis.psm1  # Analysis module
├── skills/
│   └── navigator.md           # Claude skill
├── README.md                  # This file
├── CHANGELOG.md               # Version history
├── ROADMAP.md                 # Future features
├── LICENSE                    # MIT license
└── .gitignore                 # Git ignore rules
```

**Optional documentation:**
- EXECUTIVE-SUMMARY.md - Business overview
- FEATURE-ANALYSIS.md - Analysis feature details
- ANALYSIS-FEATURE-IMPLEMENTED.md - Implementation notes

### Version Management

**Check current version:**
```powershell
# In README.md
# Version badge shows current version

# In CHANGELOG.md
# Latest version at top
```

**Update to new version:**
```powershell
# If installed as skill
.\install-skill.ps1 -Update

# If using directly
git pull  # (if from Git)
# Or download new ZIP
```

---

## 🔧 Troubleshooting

### Common Issues

#### "Azure CLI not found"

**Error:**
```
❌ Azure CLI not found
```

**Solution:**
```powershell
# Install Azure CLI
winget install -e --id Microsoft.AzureCLI

# Or download from: https://aka.ms/installazurecli

# Restart terminal after installation
```

#### "PowerShell version too old"

**Error:**
```
❌ Script requires PowerShell 7.0 but found 5.1
```

**Solution:**
```powershell
# Install PowerShell 7
winget install --id Microsoft.Powershell --source winget

# Or download from: https://aka.ms/powershell

# Open new PowerShell 7 window (not Windows PowerShell)
```

#### "Not authenticated with Azure"

**Error:**
```
❌ Not authenticated with Azure CLI
```

**Solution:**
```powershell
# Login to Azure
az login

# Browser opens, sign in with your credentials

# Verify authentication
az account show
```

#### "No environments found"

**Error:**
```
❌ No environments found
```

**Solutions:**
1. **Check permissions:**
   ```powershell
   # Verify you have Power Platform admin role
   # Contact your administrator if needed
   ```

2. **Verify tenant:**
   ```powershell
   # Check current Azure subscription
   az account show

   # Switch if needed
   az account set --subscription "Your Subscription"
   ```

3. **Check API access:**
   ```powershell
   # Test BAP API connectivity
   .\Demo-Navigator.ps1
   ```

#### "Failed to create bot - 400 Bad Request"

**Error:**
```
❌ Failed to create bot: 400 Bad Request
```

**Common causes:**
1. **Schema name conflict** - Bot with same schema name exists
2. **Invalid characters** - Bot name contains special characters
3. **Missing required fields**

**Solution:**
```powershell
# Try different parameters:
# 1. Change bot name
# 2. Ensure schema name is unique
# 3. Check for special characters
```

#### "Component import failed"

**Error:**
```
❌ Component XYZ failed to import
```

**Solution:**
```powershell
# This usually happens due to:
# 1. Dependency issues (import order)
# 2. Environment differences

# Workaround:
# 1. Retry the migration
# 2. Use Template-only migration first, then add components manually
# 3. Check Navigator ROADMAP.md for known issues
```

#### "/navigator command not found"

**Error:**
```
Command "/navigator" not recognized
```

**Solutions:**
1. **Skill not installed:**
   ```powershell
   .\install-skill.ps1
   ```

2. **Claude Code not restarted:**
   - Close and reopen Claude Code completely

3. **Wrong installation location:**
   ```powershell
   # Check skill directory exists
   ls ~/.claude/skills/navigator/

   # If not, reinstall
   .\install-skill.ps1
   ```

4. **Check skill file:**
   ```powershell
   # Verify skill definition exists
   cat ~/.claude/skills/navigator/navigator.md
   ```

### Getting Help

**Check documentation:**
1. README.md (this file)
2. CHANGELOG.md - Known issues and fixes
3. ROADMAP.md - Planned features

**Test your setup:**
```powershell
# Run demo mode
.\Demo-Navigator.ps1

# Check prerequisites
.\Start-Navigator.ps1
```

**Common solutions:**
- Restart PowerShell terminal
- Re-authenticate: `az login`
- Reinstall skill: `.\install-skill.ps1 -Update`
- Check Azure permissions

**Enable verbose output:**
```powershell
# For debugging
$VerbosePreference = "Continue"
.\Invoke-Navigator.ps1
```

---

## 🚀 Advanced Usage

### Automation & CI/CD

**Future capability (planned v2.0):**

Navigator is designed to support automation scenarios:

```powershell
# Unattended migration (planned feature)
.\Invoke-Navigator.ps1 `
  -SourceEnvironment "Development" `
  -TargetEnvironment "Production" `
  -BotName "Customer Service Bot" `
  -MigrationType "Full" `
  -Unattended `
  -ConfigFile "migration-config.json"
```

**Current workaround:**
- Use Demo-Navigator.ps1 to test connectivity
- Wrap Invoke-Navigator.ps1 in automation scripts
- Pre-authenticate with `az login --service-principal`

### Custom Modifications

Navigator is open source (MIT license) - customize as needed!

#### Modify Analysis Logic

**Edit:** `Modules\Copilot-Analysis.psm1`

```powershell
# Customize complexity scoring
function Get-ComplexityScore {
    # Adjust weights here
    $overall = ($topicScore * 0.3) +      # Topic weight
               ($customScore * 0.25) +     # Custom logic weight
               ($integrationScore * 0.2) + # Integration weight
               ($knowledgeScore * 0.15) +  # Knowledge weight
               ($sizeScore * 0.1)          # Size weight
}
```

#### Add New Features

**Example: Add custom validation**

```powershell
# In Invoke-Navigator.ps1
function Test-CustomValidation {
    param($Bot)

    # Add your validation logic
    if ($Bot.name -match "Test") {
        Write-Warning "Bot name contains 'Test'"
        return $false
    }

    return $true
}
```

#### Integration Examples

**PowerShell Module:**
```powershell
# Import Navigator functions
Import-Module "C:\path\to\Modules\Copilot-Analysis.psm1"

# Use in your scripts
$analysis = Get-CopilotAnalysis -CopilotData $myData
```

**Azure DevOps Pipeline:**
```yaml
# azure-pipelines.yml
steps:
  - task: PowerShell@2
    inputs:
      targetType: 'inline'
      script: |
        az login --service-principal --username $(clientId) --password $(clientSecret) --tenant $(tenantId)
        .\Invoke-Navigator.ps1
```

### Performance Tuning

**For large copilots (100+ components):**

1. **Increase timeout:**
   ```powershell
   # In Invoke-Navigator.ps1
   $timeout = 300  # 5 minutes instead of default 2
   ```

2. **Batch operations:**
   - Script already uses batched API calls
   - No changes needed

3. **Parallel processing:**
   - Currently sequential for safety
   - Can be parallelized for speed (at your own risk)

---

## 🤝 Contributing

### Reporting Issues

Found a bug or have a suggestion?

1. **Check existing issues** in CHANGELOG.md
2. **Provide details:**
   - PowerShell version
   - Azure CLI version
   - Error message (full text)
   - Steps to reproduce
   - Expected vs actual behavior

### Submitting Changes

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Update documentation
6. Submit pull request

### Development Setup

```powershell
# Clone the repo
git clone <repo-url>
cd copilot-zapper

# Create dev branch
git checkout -b feature/my-feature

# Make changes
# Test with: .\Demo-Navigator.ps1

# Commit
git add .
git commit -m "Add my feature"

# Push
git push origin feature/my-feature
```

### Code Standards

- ✅ Use PowerShell 7+ syntax
- ✅ Include comment-based help
- ✅ Follow existing naming conventions
- ✅ Add error handling
- ✅ Update CHANGELOG.md
- ✅ Test on clean environment

---

## 📄 License

MIT License - Free to use, modify, and distribute.

See [LICENSE](LICENSE) file for full terms.

---

## 🧭 About Navigator

**Navigator** reflects the tool's core mission: to guide copilots across the complex terrain of Power Platform environments.

Like a skilled pathfinder, Navigator:
- **Charts the Course** - Plans migrations with precision
- **Navigates Obstacles** - Handles complexity smoothly
- **Guides to Destination** - Ensures safe arrival
- **Maps the Territory** - Analyzes and documents copilots
- **Supports the Journey** - Provides clear guidance every step

### Version History

| Version | Date | Highlights |
|---------|------|------------|
| 1.1.0 | 2026-03-28 | Added copilot analysis feature |
| 1.0.0 | 2026-03-28 | Initial release |

### Created By

Copilot Zapper Team

### Powered By

- PowerShell 7.0+
- Azure CLI
- Microsoft Power Platform APIs
- Claude Code (optional)

---

## 📞 Support

**Documentation:**
- 📖 README.md (this file)
- 📋 CHANGELOG.md
- 🗺️ ROADMAP.md
- 📊 EXECUTIVE-SUMMARY.md
- 🔍 FEATURE-ANALYSIS.md

**Quick Links:**
- [PowerShell Download](https://aka.ms/powershell)
- [Azure CLI Download](https://aka.ms/installazurecli)
- [Power Platform Admin Center](https://admin.powerplatform.microsoft.com/)
- [Copilot Studio](https://copilotstudio.microsoft.com/)

---

## 📖 Quick Reference Card

### Installation & Setup

```powershell
# Prerequisites
$PSVersionTable.PSVersion  # Check PowerShell version (need 7.0+)
az --version               # Check Azure CLI
az login                   # Authenticate

# Install as Claude Code skill
cd C:\code\copilot-zapper
.\install-skill.ps1        # Install
# Restart Claude Code, then type: /navigator

# Or use directly without installing
.\Start-Navigator.ps1      # Interactive (with checks)
.\Invoke-Navigator.ps1     # Direct execution
.\Demo-Navigator.ps1       # Test mode (read-only)
```

### Quick Commands

| What You Want | Command | Notes |
|---------------|---------|-------|
| **Install skill** | `.\install-skill.ps1` | Restart Claude Code after |
| **Update skill** | `.\install-skill.ps1 -Update` | Get latest version |
| **Uninstall skill** | `.\install-skill.ps1 -Uninstall` | Remove from Claude Code |
| **Use as skill** | `/navigator` | In Claude Code |
| **Use directly** | `.\Start-Navigator.ps1` | PowerShell standalone |
| **Test setup** | `.\Demo-Navigator.ps1` | Validate environment |
| **Check auth** | `az account show` | See current user |
| **Login** | `az login` | Authenticate |

### Workflow Cheat Sheet

**Migration:**
1. Select source environment
2. Pick copilot
3. Choose type (Template/Full)
4. Customize (optional)
5. Select target environment
6. Confirm & migrate

**Analysis:**
1. Select environment
2. Pick copilot
3. View report
4. Export (optional)

### File Quick Reference

| File | What It Does | When to Use |
|------|--------------|-------------|
| `Start-Navigator.ps1` | Checks setup, runs Navigator | **First time** or troubleshooting |
| `Invoke-Navigator.ps1` | Main program (migration + analysis) | **Regular use** directly |
| `Demo-Navigator.ps1` | Tests setup without doing anything | **Testing** environment |
| `install-skill.ps1` | Installs `/navigator` in Claude Code | **Installing** as skill |
| `Modules/Copilot-Analysis.psm1` | Analysis engine | Auto-loaded by scripts |
| `skills/navigator.md` | Claude Code skill definition | Auto-loaded by Claude |

### Troubleshooting Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| PowerShell too old | `winget install Microsoft.Powershell` |
| Azure CLI missing | `winget install Microsoft.AzureCLI` |
| Not authenticated | `az login` |
| `/navigator` not found | Restart Claude Code |
| Skill not installed | `.\install-skill.ps1` |
| Script won't run | `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` |

---

**Ready to navigate your copilots?** 🧭🚀

```powershell
# Install Navigator
.\install-skill.ps1

# Start your journey
/navigator
```

---

*"Every journey begins with a single step."* - Lao Tzu

**Navigator v1.1.0** - Copilot Migration Pathfinder
