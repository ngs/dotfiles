---
name: delete-unused-sources
description: Delete all unused source files and update README.md as needed
---

# Delete Unused Sources

Detect and remove unused source files in the project, then update README.md accordingly.

## Instructions

1. Analyze project structure to identify:
   - Unused components
   - Unused utility functions
   - Unused stylesheets
   - Unused images and assets
   - Dead code

2. Check reference status of each file:
   - Track imports/exports
   - Verify actual usage
   - Consider references from test files

3. Once deletion targets are identified:
   - Display confirmation message before deletion
   - Remove related test files together
   - Check type definition files

4. Update README.md:
   - Remove descriptions about deleted files
   - Update project structure documentation
   - Update usage instructions as needed

## Safety Checks

- Never delete node_modules
- Do not touch .git directory
- Handle configuration files (.env, config, etc.) carefully
- Always ask for user confirmation before deletion