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

## Key Configuration
- **OS Requirement:** Windows (Required for PowerShell/PresentationCore audio backend).
- **Active Pack:** Controlled by `GEMINEER_PACK`.
- **Volume:** Controlled by `GEMINEER_VOLUME` (0.0 to 1.0).
- **Packs:** Support for any pack from the [OpenPeon Registry](https://github.com/PeonPing/registry).
