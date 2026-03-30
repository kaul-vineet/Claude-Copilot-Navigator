# 🧭 Navigator - Copilot Deployment Skill

> *"Every journey begins with a single step"* - Lao Tzu

**Fast testing and production deployment for Microsoft Copilot Studio across Power Platform environments**

![Version](https://img.shields.io/badge/version-2.2.0-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Power%20Platform-742774)
![Channels](https://img.shields.io/badge/channels-3-brightgreen)

---

## 🎯 What is Navigator?

> **If you build Microsoft Copilot Studio agents, you know the pain:** every time you want to test a change, you're stuck manually exporting, importing, publishing — a process that eats 10-15 minutes of your day, every single time. Multiply that across a team and environments, and you're losing hours to deployment busywork instead of building. **Navigator eliminates that entirely.**

Navigator talks directly to the Dataverse API, handles every component type (topics, knowledge sources, agent skills), and shields you from all the Power Platform ceremony. No manual exports. No solution wizards. No context-switching. Trigger it three ways — whichever fits how you work:

- 🧭 **Claude Skill** — type `/navigator` in Claude Code CLI or the VS Code Claude extension, describe what you want in plain English
- 🖥️ **VS Code extension** — `Ctrl+Shift+T` or Command Palette, never leave your IDE; progress tracked in the Navigator output channel
- ⚙️ **PowerShell directly** — `.\Navigator.ps1`, fully scriptable for CI/CD pipelines and automation

Whichever channel you use, the same deployment engine runs underneath.

- 🚀 **30-60 second deploys** — Smart Test mode pushes any agent to any environment without solution packaging
- 🏗️ **Production-grade DV Solution Migration** — full solution packaging with audit trail when governance matters
- 🔒 **Production safety built-in** — auto-escalates to DV Solution Migration when targeting Production
- 🆓 **Free and open-source** — no licences, no SaaS fees, no API keys required

**Smart Test deploy** is Navigator's default mode — and the one you'll use every day. It skips solution packaging entirely, talking directly to the Dataverse API to push your copilot and all its components (topics, triggers, agent skills) straight into any target environment in 30-60 seconds. Already got that bot in the target? It updates in place. Not there yet? It creates it. Either way, it publishes and hands you a test URL the moment it's done. No exports. No solution wizards. No waiting.

> 🔒 Targeting Production? Navigator automatically escalates to DV Solution Migration — governance stays intact without you having to think about it.

---

Navigator gives you **three ways to move copilots between environments** — and all three are real deployments, not wrappers:

### ⚡ Smart Test Mode
**For Testing & Iteration**
- ⏱️ **30-60 seconds** deployment time
- 🚫 No solution packaging
- ♻️ Updates in place
- 🧹 Easy cleanup

### 📦 DV Solution Migration
**For Production**
- ⏱️ 4-8 minutes deployment time
- ✅ Solution packaging with versioning
- 🔒 Managed components
- 📋 Complete audit trail

---

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [How It Works](#-how-it-works)
- [Usage](#-usage)
  - [How to Invoke](#-how-to-invoke-navigator)
  - [Smart Test Mode](#-smart-test-mode)
  - [DV Solution Migration](#-dv-solution-migration)
- [What Each Script Does](#-what-each-script-does)
- [Troubleshooting](#-troubleshooting)
- [Advanced Features](#-advanced-features)
- [Documentation](#-documentation)
- [FAQ](#-faq)

---

## 🚀 Quick Start

### Fastest Way to Test a Copilot

```powershell
# 1. Install prerequisites (one-time)
winget install Microsoft.PowerShell
winget install Microsoft.AzureCLI

# 2. Clone or download Navigator
cd C:\code\Claude-Copilot-Navigator

# 3. Quick deploy to test environment
.\Navigator.ps1 -Mode SmartTest
```

**That's it!** Select your copilot and target environment, and you're testing in ~40 seconds.

---

## 📦 Installation

### Prerequisites

**Minimum Requirements** (Required for all features):

| Requirement | Install Command | Why Needed |
|------------|----------------|------------|
| **PowerShell 7.0+** | `winget install Microsoft.PowerShell` | Script runtime |
| **Azure CLI** | `winget install Microsoft.AzureCLI` | Power Platform authentication |
| **Power Platform Access** | (Admin permission) | Read/write copilots |

**Optional** (Only for advanced AI features):

| Optional | Install | Use Case |
|----------|---------|----------|
| **Claude API Key** | [Get key](https://console.anthropic.com/) | AI-powered migration analysis |

> ✅ **Navigator works perfectly without API keys!** AI features are 100% optional.

---

### Installation Options

#### Option 1: As Claude Code Skill (Recommended)

If you use Claude Code, install Navigator as a skill for easy access:

```powershell
# Run the installer
cd C:\code\Claude-Copilot-Navigator
.\install-skill.ps1
```

Then use it in Claude Code:
```
/navigator quick          # Smart Test deploy
/navigator dv             # DV Solution Migration
```

**Restart Claude Code** after installation.

> ⚠️ **Note:** The installer copies files to `~/.claude/skills/navigator/`. Two copies are maintained — your project folder and the installed copy. After any project update, re-run `.\install-skill.ps1 -Update` to keep the installed copy in sync.

---

#### Option 2: Standalone PowerShell

No installation needed! Just run the scripts directly:

```powershell
cd C:\code\Claude-Copilot-Navigator
.\Navigator.ps1
```

---

#### Option 3: VS Code Extension

**Prerequisites:** Node.js 18+, npm

```powershell
# 1. Build the extension
cd C:\code\Claude-Copilot-Navigator\vscode-extension
npm install
npm run compile

# 2. Package it
npm install -g @vscode/vsce
vsce package

# 3. Install in VS Code
code --install-extension navigator-vscode-1.0.0.vsix
```

Or sideload during development:
1. Open `vscode-extension/` in VS Code
2. Press `F5` to launch Extension Development Host

**After installing:**
- `Ctrl+Shift+T` → Smart Test
- Command Palette (`Ctrl+Shift+P`) → "Navigator: Smart Test" or "Navigator: DV Solution Migration"

---

## 🔧 How It Works

### Smart Test Mode Architecture

```
Source Environment
    ↓
1. Get copilot definition (API call)
2. Get all components (topics, triggers, skills)
    ↓
Target Environment
    ↓
3. Check if copilot exists
    ├─ Exists → Update in place (PATCH)
    └─ Not exists → Create new (POST)
    ↓
4. Update/create components
5. Publish
    ↓
✅ Done in 30-60 seconds

Result: Copilot deployed directly (NO SOLUTION)
```

**Key Points:**
- Direct Dataverse API calls
- No solution packaging overhead
- Bots exist in "Default Solution"
- Updates existing copilots automatically
- Fast and simple

---

### DV Solution Migration Mode Architecture

```
Source Environment
    ↓
1. Export copilot data
2. Get all components
    ↓
3. Create solution in target
4. Package components
5. Import solution
6. Add bot to solution
7. Publish
    ↓
✅ Done in 4-8 minutes

Result: Copilot packaged in custom solution
```

**Key Points:**
- Solution-based packaging
- Managed component support
- Full audit trail
- Version control
- Production-grade

---

### Smart Mode Detection

```powershell
# Automatic production safety
if ($Target -eq "Production") {
    $Mode = "Full"  # Always use Full for Production
}

# Command-based detection
"quick" | "test" | "deploy" → Smart Test mode
"full" | "migrate" | "production" → DV Solution Migration mode

# Default: Smart Test mode (testing is most common)
```

---

## 🎨 Usage

Navigator has two deployment modes. You can trigger either from Claude Code, PowerShell, or VS Code.

---

### 🧭 How to Invoke Navigator

#### ⭐ Claude Code Skill — Recommended

> The primary way to use Navigator. Type a natural language command and Claude handles the rest — no parameters to remember, no terminal to switch to.

**In Claude Code CLI or the VS Code Claude extension:**

```
/navigator Sales Assistant to UAT
```

```
/navigator dv Sales Assistant to Production
```

Navigator responds inline:

```
⚡ Smart Test → UAT...
[1/3] ✅ Retrieved 15 components
[2/3] ✅ Updated copilot
[3/3] ✅ Published

✅ Done in 35 seconds!
🔗 Test URL: https://copilotstudio.microsoft.com/...
```

- Natural language — describe what you want
- No parameters to remember
- Progress shown in the conversation
- Works in Claude Code CLI and VS Code Claude extension

---

#### 2️⃣ VS Code Extension

Never leave your IDE. Use the keyboard shortcut or Command Palette:

```
Ctrl+Shift+T                          → Smart Test
Ctrl+Shift+P → Navigator: Smart Test  → Smart Test
Ctrl+Shift+P → Navigator: DV Solution Migration → DV mode
```

1. Enter bot name in the input box
2. Select target environment from the dropdown
3. Watch progress notifications: `[1/3]`, `[2/3]`, `[3/3]`
4. Click **"Open Test Chat"** on completion (Smart Test)

Full output is captured in the **Navigator output channel**.

---

#### 3️⃣ PowerShell Script

For automation, CI/CD pipelines, or when running without Claude Code:

```powershell
.\Navigator.ps1 -Mode SmartTest -BotName "Sales Assistant" -Target "UAT"
.\Navigator.ps1 -Mode DV -BotName "Sales Assistant" -Target "Production"
```

- Full parameter control
- Scriptable and automatable
- Works in GitHub Actions and Azure DevOps

---

### ⚡ Smart Test Mode

**Use when:** Testing changes, iterating, validating before production

**What happens:**
1. ✅ Gets copilot and all components from source environment
2. ✅ Deploys directly to target (no solution packaging)
3. ✅ Updates in place if already exists, creates new if not
4. ✅ Publishes immediately
5. ✅ Opens test chat in browser

**Time:** 30-60 seconds

```powershell
# Interactive — prompts for copilot and environment
.\Navigator.ps1 -Mode SmartTest

# With parameters
.\Navigator.ps1 -Mode SmartTest -BotName "Sales Assistant" -Source "Development" -Target "UAT" -OpenTestChat
```

> 💡 Bots deployed via Smart Test land in the Default Solution. To clean up, just delete the bot from the target environment.

---

### 📦 DV Solution Migration

**Use when:** Deploying to production, need audit trail, formal ALM process

**What happens:**
1. ✅ Exports copilot from source
2. ✅ Prompts for migration type (Full Copilot or Template Only)
3. ✅ Prompts for parameter customisation (name, description, language, schema name)
4. ✅ Creates solution: `Navigator_SalesAssistant_YYYYMMDD_HHMMSS`
5. ✅ Packages all components with dependencies
6. ✅ Imports as managed solution
7. ✅ Publishes with full audit trail

**Time:** 4-8 minutes

```powershell
# Interactive
.\Navigator.ps1 -Mode DV

# To Production
.\Navigator.ps1 -Mode DV -BotName "Sales Assistant" -Target "Production"
```

> 🔒 **Production Safety:** Targeting "Production" automatically switches to DV Solution Migration, even if Smart Test was specified.

---

#### Migration Types (DV mode only)

| Type | What Migrates | Use Case |
|------|--------------|----------|
| **Full Copilot** | Everything — topics, knowledge, skills, triggers | Standard migration |
| **Template Only** | Bot structure only, no content | Create a blank template from an existing bot |

---

#### Parameter Customisation (DV mode only)

During DV migration you are prompted to optionally override:

| Parameter | Example | Notes |
|-----------|---------|-------|
| **Bot Name** | `Sales Assistant v2` | Rename at import time |
| **Description** | `Production release` | Override the bot description |
| **Language** | `1033` | Locale code — 1033 = English (US) |
| **Schema Name** | `new_SalesAssistant` | Dataverse unique name |

Press Enter to keep the original value for any field.

---

## 📂 What Each Script Does

### Main Scripts

#### `Navigator.ps1`
**The dual-mode deployment script**

```powershell
# Smart Test mode (default)
.\Navigator.ps1 -Mode SmartTest

# DV Solution Migration mode
.\Navigator.ps1 -Mode DV
```

**What it does:**
- Routes between Quick and DV Solution Migration modes
- Production safety (auto-switches to DV Solution Migration)
- Interactive or parametric usage
- Progress reporting
- Error handling

**Use this for:** All deployments (Quick or Full)

---

#### `install-skill.ps1`
**Skill installer for Claude Code**

```powershell
# Install
.\install-skill.ps1

# Update
.\install-skill.ps1 -Update

# Uninstall
.\install-skill.ps1 -Uninstall
```

**What it does:**
- Installs Navigator as Claude Code skill
- Copies files to `~/.claude/skills/navigator/`
- Prerequisite checking
- Version management

**Use this for:** Installing Navigator as a Claude Code skill

---

### Modules

#### `scripts/Copilot-Core.psm1`
**Shared utilities used by both Quick and DV Solution Migration modes**

Functions:
- Authentication (`Get-AuthHeaders`)
- Environment management (`Get-Environments`, `Select-Environment`)
- Copilot operations (`Get-CopilotDefinition`, `Publish-Copilot`)
- Helper functions (`Remove-SystemFields`)

---

#### `scripts/Copilot-QuickDeploy.psm1`
**Smart Test logic (no solutions)**

Functions:
- `Invoke-QuickDeploy` - Main quick deploy function
- Direct bot creation/update
- Component management
- Fast iteration support

**Used by:** Smart Test mode only

---

#### `scripts/Copilot-Analysis.psm1`
**Built-in analysis features**

Functions:
- Complexity scoring
- Quality assessment
- Migration readiness
- Pattern recognition

**Works without API keys!**

---

## 🔍 Troubleshooting

### Smart Test Mode Issues

#### "Component failed to update"
**Cause:** Component has dependencies not in target environment

**Solution:**
```powershell
# Check for missing connections, flows, or custom connectors
# Either:
1. Import dependencies first, or
2. Use DV Solution Migration mode (handles dependencies)
```

#### "Copilot already exists"
**This is normal!** Smart Test mode updates existing copilots.

If you want a fresh copy:
```powershell
# Delete existing copilot in target first
# Then run Quick deploy
```

---

### DV Solution Migration Mode Issues

#### "Solution import failed"
**Common causes:**
- Missing dependencies
- Environment version mismatch
- Permission issues

**Solution:**
```powershell
# 1. Check dependencies
# 2. Verify target environment version
# 3. Confirm admin permissions
```

---

### Authentication Issues

#### "Failed to get access token"
```powershell
# Re-login to Azure CLI
az login

# Verify correct subscription
az account show
```

---

### General Issues

#### "Prerequisites not met"
```powershell
# Check PowerShell version
$PSVersionTable.PSVersion  # Must be 7.0+

# Check Azure CLI
az version  # Must be installed

# Re-run prerequisite check
.\install-skill.ps1 -WhatIf
```

---

### Getting Help

1. **Check logs:** Review script output for error messages
2. **GitHub Issues:** Report bugs at [GitHub repository]
4. **Community:** Ask in discussions

---

## 🎓 Advanced Features

### AI-Powered Analysis (Optional)

Navigator includes optional AI features for enhanced migration analysis:

**Features:**
- Migration readiness assessment
- Component failure diagnosis
- Post-migration review
- Intelligent recommendations

**Setup:**
```powershell
# Set API key (optional)
$env:ANTHROPIC_API_KEY = "sk-ant-your-key-here"

# Then use Navigator normally
.\Navigator.ps1
```

**Skill-Aware Mode:**
When running as Claude Code skill, uses Claude Code's built-in AI (no API key needed!)

**Learn More:** Set `$env:ANTHROPIC_API_KEY` and run Navigator normally — AI analysis activates automatically.

---

### Automation & CI/CD

Navigator works great in automation scenarios:

**GitHub Actions Example:**
```yaml
- name: Deploy Copilot to UAT
  run: |
    pwsh -Command "
      .\Navigator.ps1 `
        -Mode SmartTest `
        -BotName 'Sales Assistant' `
        -Target 'UAT' `
        -NoConfirm
    "
```

**Azure DevOps Example:**
```yaml
- task: PowerShell@2
  inputs:
    targetType: 'filePath'
    filePath: '$(System.DefaultWorkingDirectory)/Navigator.ps1'
    arguments: '-Mode SmartTest -BotName "Sales Assistant" -Target "UAT" -NoConfirm'
```

---

### Batch Operations

Deploy multiple copilots:

```powershell
$copilots = @("Sales Assistant", "Support Bot", "Product Catalog")

foreach ($bot in $copilots) {
    .\Navigator.ps1 `
        -Mode SmartTest `
        -BotName $bot `
        -Target "UAT" `
        -NoConfirm
}
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Main documentation |
| [CHANGELOG.md](planning/CHANGELOG.md) | Version history |
| [ROADMAP.md](planning/ROADMAP.md) | Future plans |

---

## ❓ FAQ

### General

**Q: Do I need an API key to use Navigator?**
**A:** No! Navigator works perfectly without any API keys. AI features are 100% optional.

**Q: What's the difference between Quick and DV Solution Migration mode?**
**A:**
- **Quick:** 30-60s, no solution, perfect for testing
- **Full:** 4-8min, with solution, perfect for production

**Q: Can I use Navigator without Claude Code?**
**A:** Yes! Just run the PowerShell scripts directly.

### Technical

**Q: How does Smart Test mode work without solutions?**
**A:** Bots are Dataverse entities that don't require custom solutions to exist. They're automatically placed in the "Default Solution."

**Q: Can I deploy to Production with Smart Test mode?**
**A:** No. Production deployments automatically use DV Solution Migration mode for safety and compliance.

**Q: What if my copilot has dependencies?**
**A:** Smart Test mode works for simple copilots. For complex dependencies, use DV Solution Migration mode which packages everything together.

---

### Deployment

**Q: How do I test changes quickly?**
**A:** Use Smart Test mode! It's designed for rapid iteration:
```powershell
.\Navigator.ps1 quick
```

**Q: How do I deploy to production?**
**A:** Use DV Solution Migration mode for proper governance:
```powershell
.\Navigator.ps1 -Mode DV -Target "Production"
```

**Q: Can I automate deployments?**
**A:** Yes! Navigator works great in CI/CD pipelines. See [Advanced Features](#-advanced-features).

---

## 🎯 Key Takeaways

### For End Users

✅ **Smart Test** when testing (30-60 seconds)
✅ **DV Solution Migration** when going to production (4-8 minutes)
✅ **No API keys required** (works out-of-the-box)
✅ **Three ways to use** (Skill, PowerShell, VS Code future)
✅ **Production safety** (auto-switches to DV Solution Migration mode)

### For Administrators

✅ **Easy installation** (install-skill.ps1)
✅ **Minimal prerequisites** (PowerShell 7 + Azure CLI)
✅ **Enterprise-ready** (Azure AD auth, audit trails)
✅ **CI/CD friendly** (scriptable, automatable)
✅ **Comprehensive docs** (technical guides available)

### For Developers

✅ **Modular architecture** (Core + QuickDeploy + Analysis + LLM)
✅ **Clean code structure** (well-documented modules)
✅ **Extensible design** (easy to add features)
✅ **Open documentation** (architecture decisions explained)

---

## 📊 Comparison: Smart Test vs DV Solution Migration

| Aspect | Smart Test Mode | DV Solution Migration Mode |
|--------|-----------|-----------|
| **Time** | 30-60 seconds | 4-8 minutes |
| **Solution** | No (direct deploy) | Yes (packaged) |
| **Overwrites** | Yes (updates in place) | No (creates new version) |
| **Best For** | Testing, iteration | Production, ALM |
| **Cleanup** | Delete bot | Delete solution |
| **Audit Trail** | Minimal | Complete |
| **Dependencies** | Manual | Automatic |
| **Version Control** | Not tracked | Fully tracked |
| **Cost** | $0 | $0 |
| **API Calls** | ~5-10 | ~20-30 |
| **Target Envs** | Dev, Test, UAT | Production |
| **When to Use** | Daily testing | Release deployments |

---

## 🚀 Next Steps

### New Users

1. **Install prerequisites** (PowerShell 7, Azure CLI)
2. **Download Navigator**
3. **Try Quick deploy** to test environment
4. **Join the community**

### Contributors

1. **Check [ROADMAP.md](planning/ROADMAP.md)** for planned features
2. **Submit issues** or PRs
3. **Help improve documentation**

---

## 📜 License

MIT License - See [LICENSE](LICENSE) file for details

---

## 🙏 Acknowledgments

- Microsoft Copilot Studio team for the platform
- Anthropic for Claude AI (optional features)
- PowerShell community
- All contributors and users

---

## 📞 Support

- **Issues:** GitHub Issues
- **Discussions:** GitHub Discussions
- **Email:** [Your contact]

---

**🧭 Navigator v2.0 - Fast testing. Production-ready deployment. Your choice.**

*One tool. Two modes. Three channels. Complete solution.*

---

**Version:** 2.0.0
**Last Updated:** 2026-03-28
**Status:** ✅ Production Ready
