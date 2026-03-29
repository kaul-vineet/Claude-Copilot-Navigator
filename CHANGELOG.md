# Changelog

All notable changes to Navigator - Copilot Migration Pathfinder will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-03-28

### Added
- 🖥️ **Channel 3: VS Code Extension** (`vscode-extension/`)
  - `Ctrl+Shift+T` keyboard shortcut for Quick Deploy
  - Command Palette: "Navigator: Quick Deploy" and "Navigator: Full Migration"
  - Bot name input box + target environment picker (QuickPick dropdown)
  - Progress notification showing [1/3], [2/3], [3/3] milestones
  - "Open Test Chat" button on Quick Deploy success
  - Dedicated Navigator output channel for full script output
  - Error notification with "Show Output" button on failure
  - Calls existing `Invoke-Navigator-Enhanced.ps1` — zero duplicated logic

- 📁 **Project structure improvements**
  - `planning/` folder for session notes and planning docs (gitignored)
  - `temp/` folder for exported bot JSON artifacts (gitignored)

### Fixed
- 🐛 `az powerplatform` extension dependency removed — environments now fetched via REST API directly (`https://api.bap.microsoft.com`)
- 🐛 `Select-Copilot` not recognized — removed nested `Import-Module` from `Copilot-QuickDeploy.psm1` that was pulling `Copilot-Core` out of session scope
- 🐛 Environment names blank — fixed `PSCustomObject` vs hashtable indexing issue; added `@()` array forcing; added `displayName → friendlyName → name` fallback chain
- 🐛 401 Unauthorized on Dataverse calls — `Get-AuthHeaders` now accepts `-Resource` parameter; all Dataverse callers pass `$envUrl` as resource for correctly scoped tokens
- 🐛 `$filter` unsupported on `bots` entity — switched to client-side filtering (`Where-Object`) for bot name lookups
- 🐛 Empty `BotId` on create — added `Prefer: return=representation` header to POST so Dataverse returns the created entity
- 🐛 `_publishedby_value cannot be updated to null` — `Remove-SystemFields` now strips all `_*_value` reference fields automatically
- 🐛 Components not migrated — replaced hardcoded type filters (0/1/2) with `All` collection capturing every `componenttype`; resolves missing Knowledge (type 16), Topics (type 9), Agent skills (type 15)

### Changed
- Modules moved from `scripts/Modules/` to flat `scripts/` — matches Claude Code skill spec
- `SKILL.md` now has required frontmatter (`name`, `description`, `triggers`)
- Source environment selection is now interactive (no longer hardcoded to "Development")
- `docs/` folder gitignored (internal planning docs)
- README cleaned of v1/v2 migration references and internal docs links

### Removed
- `Copilot-LLM-Intelligence.psm1` — not imported by any script
- Duplicate root-level scripts (`Invoke-Navigator-Enhanced.ps1`, `Invoke-Navigator.ps1`, `Modules/`)
- `README-v1.1.0-backup.md`
- All `docs/` internal planning documents

---

## [2.0.0] - 2026-03-28

### Added
- 🚀 **MAJOR: Dual-Mode Deployment System**
  - **Quick Mode** (default) - Fast testing deployment (30-60 seconds, no solutions)
  - **Full Mode** - Production deployment with solution packaging (4-8 minutes)
  - Smart mode detection based on target environment (Production always uses Full mode)
  - New enhanced script: `Invoke-Navigator-Enhanced.ps1`

- ⚡ **Quick Deploy Module** (`Modules\Copilot-QuickDeploy.psm1`)
  - Direct copilot deployment without solution creation
  - Updates existing copilots in place
  - Perfect for rapid testing and iteration
  - No solution artifacts to manage
  - Automatic cleanup (just delete the bot when done)

- 🧩 **Core Shared Module** (`Modules\Copilot-Core.psm1`)
  - Shared utilities used by both Quick and Full modes
  - Authentication, environment management, copilot operations
  - Common helper functions
  - Consistent behavior across modes

- 📚 **Comprehensive Documentation Suite** (in `docs/` folder)
  - `ARCHITECTURE-DECISION.md` - Why dual-mode integration was chosen
  - `BOTS-WITHOUT-SOLUTIONS.md` - Technical explanation of bots without solutions
  - `THREE-CHANNEL-ARCHITECTURE.md` - How the three channels work (Claude Skill, PowerShell, VS Code)
  - `IMPLEMENTATION-GUIDE.md` - Step-by-step implementation details

- 🎯 **Enhanced Skill Definition** (`skills/navigator-enhanced.md`)
  - Updated for dual-mode support
  - Clear instructions for Quick vs Full mode
  - Example conversations and workflows
  - Mode selection logic

### Changed
- **Default behavior:** Quick mode is now default for all non-production deployments
- **Production safety:** Production target automatically switches to Full mode regardless of user request
- **Three-channel support:** Same functionality accessible via Claude Skill, PowerShell, and VS Code (future)
- Enhanced command parsing: Supports "quick", "test", "deploy", "full", "migrate", "production" keywords
- Improved user experience with clear mode indicators and timing estimates

### Architecture
- **Quick Mode:**
  - Deploys copilot directly to target environment
  - No solution packaging overhead
  - Updates existing copilots in place (overwrites)
  - Fast: 30-60 seconds average
  - Use case: Testing, iteration, development

- **Full Mode:**
  - Creates solution with auto-generated name
  - Packages all components with dependencies
  - Managed solution support
  - Slower: 4-8 minutes average
  - Use case: Production, formal ALM, audit trail

### Technical Details
- Bots can exist without custom solutions (in Default Solution)
- Solutions are optional packaging for ALM, not runtime requirements
- Quick deploy creates/updates bots as unmanaged entities
- Full deploy creates managed solutions for production governance

### Breaking Changes
- None - Existing `Invoke-Navigator.ps1` continues to work for Full mode
- New `Invoke-Navigator-Enhanced.ps1` provides dual-mode access
- Fully backward compatible with v1.x workflows

### Migration from v1.x
- v1.x users: Continue using `Invoke-Navigator.ps1` (unchanged)
- v2.0 users: Use `Invoke-Navigator-Enhanced.ps1` for Quick and Full modes
- Both scripts can coexist

## [1.1.0] - 2026-03-28

### Added
- 🔍 **NEW: Copilot Analysis Feature** - Comprehensive copilot analysis without external APIs
  - Analyze copilot structure, topics, skills, and knowledge sources
  - Complexity scoring system (0-10 scale with breakdown)
  - Quality assessment with good practices and improvement suggestions
  - Migration readiness estimation
  - Automated summary generation
  - Export analysis as Markdown or JSON
  - New analysis module (`Modules\Copilot-Analysis.psm1`)
- 🧭 **NEW: Automatic Solution Management** - Clean solution creation for each import
  - Auto-creates new solution for each copilot import
  - Naming pattern: `Navigator_BotName_YYYYMMDD_HHMMSS`
  - Prevents copilots from going to Default Solution
  - Includes bot and all components in the new solution
  - Better ALM (Application Lifecycle Management) support
- 🎯 Main menu system to choose between Migration and Analysis
- 📊 Interactive analysis workflow with detailed reports
- ✅ Quality metrics: Good practices detection, improvement suggestions, issue identification
- 📈 Complexity metrics: Topics, custom logic, integrations, knowledge, size
- ⏱️ Migration time estimation based on complexity
- 💾 Multiple export formats for analysis reports (MD, JSON, Text)

### Changed
- Renamed from "Copilot Migration Commander" to "Copilot Migration Pathfinder"
- Updated banner and branding from military theme (🎖️) to navigation theme (🧭)
- Updated quotes from "In the desert, the tank is king" to "Every journey begins with a single step"
- Refactored main execution to show operation selection menu
- Main workflow now returns to menu after completion instead of exiting

### Fixed
- 🐛 **CRITICAL: Import Error 0x80060888** - Fixed "CRM do not support direct update of Entity Reference properties"
  - Removed `parentbotid` field before setting `@odata.bind` navigation property
  - Now properly removes all system fields and entity references before import
  - Prevents Dataverse API error when importing bot components
- 🐛 **Missing Components Import** - Fixed only Topics being imported
  - Now imports ALL component types: Topics, Triggers, AND Skills
  - Previously Triggers and Skills were counted but not actually imported
  - Components now correctly linked to parent bot using navigation properties

### Documentation
- 📚 Enhanced README to 56KB with comprehensive documentation
- 📂 Added Project Structure section explaining all scripts and modules
- ⚡ Documented test-setup.ps1 quick prerequisites checker
- 🏗️ Added Solution Management feature documentation
- 📦 Updated Distribution section with current file inventory
- 🎨 Updated Demo-Navigator.ps1 branding to "Pathfinder"

## [1.0.0] - 2026-03-28

### Added
- 🧭 Initial release of Navigator - Copilot Migration Pathfinder
- Interactive environment selection with beautiful ASCII UI
- Source environment copilot discovery and listing
- Support for both Template and Full Copilot migration
- Parameter customization during migration:
  - Bot Name
  - Description
  - Language
  - Schema Name
- Real-time progress bars for export and import operations
- Automatic migration report generation
- Export file creation for backup and audit purposes
- Azure CLI authentication integration
- Comprehensive error handling and logging
- Color-coded console output for better UX
- Box-drawing characters for elegant menus
- Tabular data display for copilot listings
- Environment metadata validation
- Bot component migration (topics, triggers, skills, knowledge)
- Automatic bot publishing after import
- Migration summary and confirmation step

### Features
- 📋 Interactive menu-driven interface
- 🎯 Multi-environment support
- 🔐 Secure authentication via Azure CLI
- 🚀 Batched API operations for efficiency
- 📊 Detailed migration reports
- ⚙️ Flexible parameter customization
- ✅ Pre-flight validation checks
- 🔄 Template-only migration option
- 🤖 Full copilot migration with all components

### Technical Details
- PowerShell 7.0+ requirement
- Uses Dataverse OData v9.2 API
- Business Application Platform API integration
- OAuth 2.0 bearer token authentication
- JSON-based export format
- In-memory component caching

### Documentation
- Comprehensive README with usage instructions
- Skill definition for Claude integration
- Troubleshooting guide
- Best practices documentation
- API endpoint reference
- Security considerations

### Scripts
- `Invoke-Navigator.ps1` - Main migration script
- `Start-Navigator.ps1` - Launcher with prerequisite checks
- `navigator.skill.md` - Claude skill definition
- `SKILL_HANDLER.md` - Skill handler documentation

## [Unreleased]

### Planned Features
- [ ] Bulk migration support (multiple copilots at once)
- [ ] Configuration file support for unattended migrations
- [ ] Rollback functionality
- [ ] Differential sync (update existing bots)
- [ ] Environment variable support in bot definitions
- [ ] Integration with Azure DevOps pipelines
- [ ] GitHub Actions workflow templates
- [ ] Migration scheduling
- [ ] Email notifications on completion
- [ ] Web UI dashboard
- [ ] Support for migrating:
  - [ ] Environment variables
  - [ ] Connection references
  - [ ] Custom connectors
  - [ ] Solution-aware components
- [ ] Advanced filtering options
- [ ] Migration history tracking
- [ ] Compare tool (diff between environments)
- [ ] Dry-run mode with simulation
- [ ] Performance metrics and analytics
- [ ] Multi-tenant support
- [ ] Role-based access control

### Ideas for Future
- Integration with Power Platform ALM
- Support for other Power Platform resources:
  - Power Apps
  - Power Automate flows
  - Dataverse tables
  - Model-driven apps
- CI/CD pipeline templates
- Terraform/Bicep integration
- Monitoring and alerting
- Cost estimation for migrations

---

## Version History

| Version | Date       | Description                                          |
|---------|------------|------------------------------------------------------|
| 2.1.0   | 2026-03-28 | VS Code extension (Channel 3), bug fixes             |
| 2.0.0   | 2026-03-28 | Dual-mode deployment, three-channel architecture     |
| 1.1.0   | 2026-03-28 | Added copilot analysis feature                       |
| 1.0.0   | 2026-03-28 | Initial release                                      |

---

**Legend:**
- 🧭 Major feature
- 🔍 Analysis/Discovery
- 🚀 Enhancement
- 🐛 Bug fix
- 📋 Documentation
- 🔐 Security
- ⚠️ Breaking change
- 📊 Analytics/Reporting
- ⚙️ Configuration
