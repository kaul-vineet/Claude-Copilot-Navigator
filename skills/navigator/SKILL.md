---
name: navigator
description: Deploy Microsoft Copilot Studio bots between Power Platform environments using Quick (30-60s) or Full (4-8min) mode
triggers:
  - /navigator
---

# Navigator v2.0 - Enhanced Copilot Deployment Tool

## Quick Reference

```bash
# Quick Deploy (default - for testing)
/navigator Sales Assistant to UAT
/navigator quick

# Full Migration (with solution - for production)
/navigator full
/navigator to Production
```

---

## Two Deployment Modes

### ⚡ Quick Mode (Default)

**Purpose:** Fast testing and iteration

**Characteristics:**
- ⏱️ Speed: 30-60 seconds
- 📦 Solution: No solution created
- ♻️ Overwrites: Yes (updates in place)
- 🎯 Best for: Testing, development, iteration

**Use when:**
- Testing changes quickly in UAT/Test
- Iterating on copilot development
- Validating functionality before production
- Quick demos or POCs

**Example:**
```
User: /navigator Sales Assistant to UAT

Result:
- Copilot deployed directly to UAT
- No solution packaging
- Ready to test in ~35 seconds
- Test chat opens automatically
```

---

### 📦 Full Mode

**Purpose:** Production deployment with governance

**Characteristics:**
- ⏱️ Speed: 4-8 minutes
- 📦 Solution: Yes (auto-created with version)
- ♻️ Overwrites: No (creates new solution)
- 🎯 Best for: Production, formal ALM

**Use when:**
- Deploying to Production
- Need audit trail and versioning
- Compliance requirements
- Formal release process

**Example:**
```
User: /navigator full to Production

Result:
- Solution created: Navigator_SalesAssistant_20260328_143000
- Copilot packaged with all dependencies
- Deployed as managed solution
- Complete in ~5 minutes
```

---

## Instructions for Claude

When user invokes Navigator, follow these steps:

### Step 1: Parse Command

Extract from user input:
- **Mode:** "quick", "full", "test", "deploy", "migrate", "production"
- **Bot name:** Copilot name if specified
- **Target environment:** If specified

**Examples:**
- `/navigator Sales Assistant to UAT` → Quick mode, bot="Sales Assistant", target="UAT"
- `/navigator quick` → Quick mode, interactive selection
- `/navigator full` → Full mode, interactive selection
- `/navigator to Production` → Full mode (auto-switch), target="Production"

---

### Step 2: Detect Mode

**Auto-select Quick mode when:**
- User says "quick", "test", "deploy"
- Target is Dev/Test/UAT/Sandbox
- User wants to "test" or "try"
- **Default if not specified**

**Auto-select Full mode when:**
- User says "full", "migrate", "production"
- Target is "Production"
- User mentions "formal deployment" or "release"

**Safety rule:** Production target ALWAYS uses Full mode, regardless of user request.

---

### Step 3: Set Environment

Indicate skill mode:
```bash
$env:CLAUDE_CODE_SKILL = "true"
```

This ensures the script knows it's running as a Claude Code skill.

---

### Step 4: Execute Deployment

Navigate to skill scripts directory and run:

**For Quick Mode:**
```bash
cd ~/.claude/skills/navigator/scripts
.\Invoke-Navigator-Enhanced.ps1 -Mode Quick -BotName "<name>" -Target "<env>" -NoConfirm
```

**For Full Mode:**
```bash
cd ~/.claude/skills/navigator/scripts
.\Invoke-Navigator-Enhanced.ps1 -Mode Full -Target "<env>" -NoConfirm
```

**Interactive Mode (no parameters):**
```bash
cd ~/.claude/skills/navigator/scripts
.\Invoke-Navigator-Enhanced.ps1 -Mode <Quick|Full>
```

---

### Step 5: Show Progress

Display script output in conversation as it executes:
- Show progress messages
- Show success/failure indicators
- Show URLs and IDs when available

---

### Step 6: Confirm Completion

When deployment completes, summarize:

**Quick Mode:**
```
✅ Quick Deploy Complete

Copilot: Sales Assistant
Target: UAT
Time: 35 seconds
Action: Updated existing copilot

🔗 Test URL:
https://copilotstudio.microsoft.com/environments/.../bots/.../canvas

Your copilot is ready to test in UAT!
```

**Full Mode:**
```
✅ Full Migration Complete

Copilot: Sales Assistant
Target: Production
Time: 4m 32s
Solution: Navigator_SalesAssistant_20260328_143000

The copilot has been deployed to Production with full solution packaging.
```

---

## Example Conversations

### Example 1: Quick Testing

```
User: I want to test Sales Assistant in UAT

Claude:
I'll quickly deploy Sales Assistant to UAT for testing.

Running Quick Deploy mode...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧭 NAVIGATOR v2.0 - Copilot Deployment Tool
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Deployment Configuration:
  Copilot:  Sales Assistant
  From:     Development
  To:       UAT
  Mode:     Quick (fast, no solution, ~30-60s)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ QUICK DEPLOY MODE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/3] Getting copilot from Development...
  ✅ Retrieved 15 components

[2/3] Deploying to UAT...
  ✅ Updated copilot in UAT

[3/3] Publishing copilot...
  ✅ Published successfully

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ QUICK DEPLOY COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Time:   35s
  Action: Updated
  Bot ID: xyz-789

🔗 Test URL:
  https://copilotstudio.microsoft.com/environments/uatid/bots/xyz-789/canvas

💡 Tip: The copilot was deployed directly (no solution). To delete, just remove the bot from UAT.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Your copilot is ready to test! The deployment took 35 seconds and updated the existing instance in UAT.
```

---

### Example 2: Production Deployment

```
User: Deploy Sales Assistant to Production

Claude:
I notice you're deploying to Production. I'll automatically use Full Migration mode for safety and proper governance.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧭 NAVIGATOR v2.0 - Copilot Deployment Tool
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔒 Target is Production - automatically switching to Full mode for safety

📋 Deployment Configuration:
  Copilot:  Sales Assistant
  From:     Development
  To:       Production
  Mode:     Full (comprehensive, with solution, ~4-8min)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 FULL MIGRATION MODE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  Full migration mode will use the original Navigator (v1.0) script
    with solution packaging and comprehensive migration.

Launching original Navigator for full migration...

[Original Navigator output follows...]

The copilot has been successfully deployed to Production with full solution packaging and audit trail.
```

---

### Example 3: Quick Command

```
User: /navigator quick

Claude:
I'll help you quickly deploy a copilot for testing.

[Interactive prompts for copilot and environment selection]

Which copilot would you like to deploy?
1. Sales Assistant
2. Support Bot
3. Product Catalog Bot

[User selects]

Which environment?
1. Test
2. UAT
3. Sandbox

[User selects, then quick deployment proceeds]
```

---

## Mode Selection Logic

```
if (command contains "production" OR target == "Production"):
    mode = Full  # Safety first!

elif (command contains "quick" OR "test" OR "deploy"):
    mode = Quick

elif (command contains "full" OR "migrate"):
    mode = Full

else:
    mode = Quick  # Default to testing
```

---

## Important Notes

### For Quick Mode:
- ✅ Perfect for daily testing and iteration
- ✅ No cleanup needed (just delete the bot when done)
- ✅ Can run multiple times (overwrites in place)
- ⚠️ Not tracked in formal ALM
- ⚠️ Not suitable for production

### For Full Mode:
- ✅ Production-grade deployment
- ✅ Full audit trail and versioning
- ✅ Managed solution support
- ⚠️ Slower (but worth it for production)
- ⚠️ Creates solution artifacts

### Production Safety:
- 🔒 Production deployments ALWAYS use Full mode
- 🔒 No Quick deploy to Production (auto-switched)
- 🔒 Proper governance enforced

---

## Troubleshooting

### Quick Mode Issues:

**"Copilot already exists"**
- This is expected - Quick mode updates the existing copilot
- The update happens automatically

**"Component failed to update"**
- Check if component has dependencies
- Verify connections exist in target environment

### Full Mode Issues:

**"Solution import failed"**
- Follow standard solution troubleshooting
- Check dependencies
- Verify environment versions match

---

## Summary

Navigator v2.0 provides two deployment modes:

| Mode | Speed | Solution | Use Case |
|------|-------|----------|----------|
| **Quick** | 30-60s | No | Testing, iteration |
| **Full** | 4-8min | Yes | Production, ALM |

**Default:** Quick mode for speed
**Production:** Always Full mode for safety

**One skill. Two modes. Complete flexibility.**
