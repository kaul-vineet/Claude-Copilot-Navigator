# Changelog

All notable changes to Navigator - Copilot Migration Pathfinder will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

| Version | Date       | Description                              |
|---------|------------|------------------------------------------|
| 1.1.0   | 2026-03-28 | Added copilot analysis feature           |
| 1.0.0   | 2026-03-28 | Initial release                          |

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
