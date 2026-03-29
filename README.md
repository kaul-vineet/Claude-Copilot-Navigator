# 🧭 Navigator v2.0 - Copilot Deployment Tool

> *"Every journey begins with a single step"* - Lao Tzu

**Fast testing and production deployment for Microsoft Copilot Studio across Power Platform environments**

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-7.0%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 🎯 What is Navigator?

Navigator is a powerful deployment tool for Microsoft Copilot Studio that gives you **two ways to move copilots between environments:**

### ⚡ Quick Mode
**For Testing & Iteration**
- ⏱️ **30-60 seconds** deployment time
- 🚫 No solution packaging
- ♻️ Updates in place
- 🧹 Easy cleanup

### 📦 Full Mode
**For Production**
- ⏱️ 4-8 minutes deployment time
- ✅ Solution packaging with versioning
- 🔒 Managed components
- 📋 Complete audit trail

---

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Usage](#-usage)
  - [Quick Deploy](#-quick-deploy-testing)
  - [Full Migration](#-full-migration-production)
  - [Three Ways to Use](#-three-ways-to-use-navigator)
- [What Each Script Does](#-what-each-script-does)
- [How It Works](#-how-it-works)
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
cd C:\code\ClaudeCopilotMgmtSkill

# 3. Quick deploy to test environment
.\Invoke-Navigator-Enhanced.ps1 -Mode Quick
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
cd C:\code\ClaudeCopilotMgmtSkill
.\install-skill.ps1
```

Then use it in Claude Code:
```
/navigator quick          # Quick deploy
/navigator full           # Full migration
```

**Restart Claude Code** after installation.

---

#### Option 2: Standalone PowerShell

No installation needed! Just run the scripts directly:

```powershell
cd C:\code\ClaudeCopilotMgmtSkill
.\Invoke-Navigator-Enhanced.ps1
```

---

#### Option 3: VS Code Extension

**Prerequisites:** Node.js 18+, npm

```powershell
# 1. Build the extension
cd C:\code\ClaudeCopilotMgmtSkill\vscode-extension
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
- `Ctrl+Shift+T` → Quick Deploy
- Command Palette (`Ctrl+Shift+P`) → "Navigator: Quick Deploy" or "Navigator: Full Migration"

---

## 🎨 Usage

### ⚡ Quick Deploy (Testing)

**Use When:** Testing changes, validating functionality, iterating on development

**Example 1: Interactive Mode**
```powershell
.\Invoke-Navigator-Enhanced.ps1 -Mode Quick
```

Follow the prompts to select copilot and target environment.

**Example 2: With Parameters**
```powershell
.\Invoke-Navigator-Enhanced.ps1 `
    -Mode Quick `
    -BotName "Sales Assistant" `
    -Source "Development" `
    -Target "UAT" `
    -OpenTestChat
```

**Example 3: Shorthand**
```powershell
.\Invoke-Navigator-Enhanced.ps1 quick
```

**What Happens:**
1. ✅ Gets copilot from Development
2. ✅ Deploys directly to UAT (no solution)
3. ✅ Updates existing copilot or creates new
4. ✅ Publishes immediately
5. ✅ Opens test chat in browser

**Time:** 30-60 seconds

---

### 📦 Full Migration (Production)

**Use When:** Deploying to production, need audit trail, formal ALM process

**Example 1: Interactive Mode**
```powershell
.\Invoke-Navigator-Enhanced.ps1 -Mode Full
```

**Example 2: To Production**
```powershell
.\Invoke-Navigator-Enhanced.ps1 `
    -Mode Full `
    -BotName "Sales Assistant" `
    -Target "Production"
```

> 🔒 **Production Safety:** Deploying to "Production" automatically uses Full mode, even if you specify Quick mode.

**What Happens:**
1. ✅ Exports copilot from source
2. ✅ Creates solution: `Navigator_SalesAssistant_YYYYMMDD_HHMMSS`
3. ✅ Packages all components with dependencies
4. ✅ Imports to target as managed solution
5. ✅ Publishes with full audit trail

**Time:** 4-8 minutes

---

### 🎯 Three Ways to Use Navigator

#### 1️⃣ Claude Code Skill

```
User: /navigator Sales Assistant to UAT

Navigator:
⚡ Quick deploying to UAT...
[1/3] ✅ Retrieved 15 components
[2/3] ✅ Updated copilot
[3/3] ✅ Published

✅ Done in 35 seconds!
🔗 Test URL: https://...
```

**Pros:**
- Natural conversation interface
- No need to remember parameters
- Progress shown in conversation
- Claude Code integration

---

#### 2️⃣ PowerShell Script

```powershell
PS> .\Invoke-Navigator-Enhanced.ps1 -Mode Quick -BotName "Sales Assistant" -Target "UAT"
```

**Pros:**
- Scriptable and automatable
- Works in CI/CD pipelines
- No Claude Code needed
- Full parameter control

---

#### 3️⃣ VS Code Extension

```
1. Press Ctrl+Shift+T in VS Code
2. Enter bot name
3. Select target environment
4. Watch progress notification
5. Click "Open Test Chat" when done
```

**Pros:**
- IDE integration — never leave VS Code
- `Ctrl+Shift+T` keyboard shortcut
- Progress notifications with milestones
- "Open Test Chat" button on completion
- Navigator output channel for full logs

---

## 📂 What Each Script Does

### Main Scripts

#### `Invoke-Navigator-Enhanced.ps1`
**The dual-mode deployment script**

```powershell
# Quick mode (default)
.\Invoke-Navigator-Enhanced.ps1 -Mode Quick

# Full mode
.\Invoke-Navigator-Enhanced.ps1 -Mode Full
```

**What it does:**
- Routes between Quick and Full modes
- Smart mode detection (Production → auto Full)
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

#### `Modules/Copilot-Core.psm1`
**Shared utilities used by both Quick and Full modes**

Functions:
- Authentication (`Get-AuthHeaders`)
- Environment management (`Get-Environments`, `Select-Environment`)
- Copilot operations (`Get-CopilotDefinition`, `Publish-Copilot`)
- Helper functions (`Remove-SystemFields`)

---

#### `Modules/Copilot-QuickDeploy.psm1`
**Quick deploy logic (no solutions)**

Functions:
- `Invoke-QuickDeploy` - Main quick deploy function
- Direct bot creation/update
- Component management
- Fast iteration support

**Used by:** Quick mode only

---

#### `Modules/Copilot-Analysis.psm1`
**Built-in analysis features**

Functions:
- Complexity scoring
- Quality assessment
- Migration readiness
- Pattern recognition

**Works without API keys!**

---

#### `Modules/Copilot-LLM-Intelligence.psm1`
**Optional AI-powered analysis**

Functions:
- `Invoke-ClaudeAPI` - API calls or skill-aware mode
- `Analyze-ComponentFailureWithLLM` - AI diagnostics
- Migration readiness analysis
- Post-migration review

**Requires:** ANTHROPIC_API_KEY (optional)

---

## 🔧 How It Works

### Quick Mode Architecture

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

### Full Mode Architecture

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
"quick" | "test" | "deploy" → Quick mode
"full" | "migrate" | "production" → Full mode

# Default: Quick mode (testing is most common)
```

---

## 🔍 Troubleshooting

### Quick Mode Issues

#### "Component failed to update"
**Cause:** Component has dependencies not in target environment

**Solution:**
```powershell
# Check for missing connections, flows, or custom connectors
# Either:
1. Import dependencies first, or
2. Use Full mode (handles dependencies)
```

#### "Copilot already exists"
**This is normal!** Quick mode updates existing copilots.

If you want a fresh copy:
```powershell
# Delete existing copilot in target first
# Then run Quick deploy
```

---

### Full Mode Issues

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
.\Invoke-Navigator-Enhanced.ps1
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
      .\Invoke-Navigator-Enhanced.ps1 `
        -Mode Quick `
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
    filePath: '$(System.DefaultWorkingDirectory)/Invoke-Navigator-Enhanced.ps1'
    arguments: '-Mode Quick -BotName "Sales Assistant" -Target "UAT" -NoConfirm'
```

---

### Batch Operations

Deploy multiple copilots:

```powershell
$copilots = @("Sales Assistant", "Support Bot", "Product Catalog")

foreach ($bot in $copilots) {
    .\Invoke-Navigator-Enhanced.ps1 `
        -Mode Quick `
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
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [ROADMAP.md](ROADMAP.md) | Future plans |

---

## ❓ FAQ

### General

**Q: Do I need an API key to use Navigator?**
**A:** No! Navigator works perfectly without any API keys. AI features are 100% optional.

**Q: What's the difference between Quick and Full mode?**
**A:**
- **Quick:** 30-60s, no solution, perfect for testing
- **Full:** 4-8min, with solution, perfect for production

**Q: Can I use Navigator without Claude Code?**
**A:** Yes! Just run the PowerShell scripts directly.

### Technical

**Q: How does Quick mode work without solutions?**
**A:** Bots are Dataverse entities that don't require custom solutions to exist. They're automatically placed in the "Default Solution."

**Q: Can I deploy to Production with Quick mode?**
**A:** No. Production deployments automatically use Full mode for safety and compliance.

**Q: What if my copilot has dependencies?**
**A:** Quick mode works for simple copilots. For complex dependencies, use Full mode which packages everything together.

---

### Deployment

**Q: How do I test changes quickly?**
**A:** Use Quick mode! It's designed for rapid iteration:
```powershell
.\Invoke-Navigator-Enhanced.ps1 quick
```

**Q: How do I deploy to production?**
**A:** Use Full mode for proper governance:
```powershell
.\Invoke-Navigator-Enhanced.ps1 -Mode Full -Target "Production"
```

**Q: Can I automate deployments?**
**A:** Yes! Navigator works great in CI/CD pipelines. See [Advanced Features](#-advanced-features).

---

## 🎯 Key Takeaways

### For End Users

✅ **Quick Deploy** when testing (30-60 seconds)
✅ **Full Migration** when going to production (4-8 minutes)
✅ **No API keys required** (works out-of-the-box)
✅ **Three ways to use** (Skill, PowerShell, VS Code future)
✅ **Production safety** (auto-switches to Full mode)

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

## 📊 Comparison: Quick vs Full

| Aspect | Quick Mode | Full Mode |
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

1. **Check [ROADMAP.md](ROADMAP.md)** for planned features
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
