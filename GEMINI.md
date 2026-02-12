# Gem-in-eer

**The tools of the future!**

Gem-in-eer is a themed notification system for the Gemini CLI, inspired by PeonPing. It provides audio feedback for CLI events using iconic unit responses.

## Technical Architecture
- **Manifest:** `gemini-extension.json` defines the extension, repository, and the `GEMINEER_PACK` setting.
- **Hooks:** `hooks/hooks.json` registers PowerShell triggers for `SessionStart`, `SessionEnd`, `AfterAgent`, `BeforeTool`, and `AfterTool`.
- **Slash Commands:** Located in `commands/gem-in-eer/`, allowing for pack listing (`/list`), setting (`/set`), and restoration (`/mashup`).
- **Audio Logic:** `scripts/play-sound.ps1` maps events to sounds and spawns a background PowerShell process using `System.Windows.Media.MediaPlayer` to avoid blocking the CLI.
- **Asset Management:** 
    - Audio files are **not** committed to Git (see `.gitignore`).
    - `scripts/manage.ps1` handles all registry tasks: listing packs, downloading specific packs, and initial setup.
    - **Auto-Setup:** On the first `SessionStart`, if the `mashup` pack is missing, `play-sound.ps1` triggers `manage.ps1 -Action setup-mashup` in the background.

## Key Configuration
- **Active Pack:** Controlled by the `GEMINEER_PACK` environment variable (set via `gemini extensions config`).
- **Packs:** Default is `mashup`, with support for `kirov`, `engineer`, or any pack from the [OpenPeon Registry](https://github.com/PeonPing/registry).
