# Gem-in-eer

**The tools of the future!**

Gem-in-eer is a sound notification system for the Gemini CLI, inspired by PeonPing. It provides audio feedback for CLI events using iconic unit responses from various games.

## Technical Architecture
- **Manifest:** `gemini-extension.json` defines the extension, repository, and the `GEMINEER_PACK` and `GEMINEER_VOLUME` settings.
- **Hooks:** `hooks/hooks.json` registers PowerShell triggers for session and tool events.
- **Slash Commands:** Located in `commands/gem-in-eer/`, for listing and setting packs.
- **Audio Logic:** `scripts/play-sound.ps1` maps events to sounds using pack manifests (`openpeon.json`) and plays them asynchronously.
- **Asset Management:** 
    - Audio files are ignored by Git.
    - `scripts/manage.ps1` handles registry listing and pack downloading.
    - Users must run `/gem-in-eer:set <pack>` to download sounds after installation.

## Path Resolution Strategy (The "Breadcrumb")
Gemini CLI slash commands (TOML) currently do not support the `${extensionPath}` variable. To work around this:
1. **Write:** Every time a hook runs (e.g., `SessionStart`), `scripts/play-sound.ps1` writes the extension's absolute path to `$env:TEMP/gemineer_path.txt`.
2. **Read:** Slash commands (`list.toml`, `set.toml`) read this temp file to locate `scripts/manage.ps1`.
This ensures commands function correctly regardless of the current working directory.

## Randomization & State
To prevent repetitive audio, the system ensures the same sound clip is never played twice in a row for the same event category.
- **State File:** This tracking data is stored locally in `.state.json`.
- **Privacy:** This file is included in `.gitignore` and is **never** committed to the repository.

## Key Configuration
- **OS Requirement:** Windows (Required for PowerShell/PresentationCore audio backend).
- **Active Pack:** Controlled by `GEMINEER_PACK`.
- **Volume:** Controlled by `GEMINEER_VOLUME` (0.0 to 1.0).
- **Packs:** Support for any pack from the [OpenPeon Registry](https://github.com/PeonPing/registry).

## Dynamic Pack Selection
When the user wants to list or set a pack, use the following logic:
1. To see all available packs, run `powershell.exe -File scripts/manage.ps1 -Action list`.
2. Present the list to the user.
3. If the user picks a pack, use the `/gem-in-eer:set <pack_name>` command.
