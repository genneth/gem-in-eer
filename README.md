# Gem-in-eer 🚀

**The tools of the future!**

Gem-in-eer is a Red Alert 2 themed notification system for the Gemini CLI. It provides audio feedback for CLI events using iconic unit responses from the Command & Conquer: Red Alert 2 universe, while allowing you to tap into the entire [PeonPing](https://github.com/PeonPing/peon-ping) sound ecosystem.

## Features

- **Iconic RA2 Sounds:** Default "mashup" pack with Soviet Engineer and Kirov Airship.
- **PeonPing Integration:** Access any pack from the [OpenPeon Registry](https://github.com/PeonPing/registry) (Warcraft, StarCraft, Portal, etc.).
- **Slash Commands:**
  - `/ra2:list`: Browse all available sound packs.
  - `/ra2:set <pack_name>`: Download and prepare a specific pack (e.g., `/ra2:set glados`).
  - `/ra2:mashup`: Restore the original RA2 experience.
- **Event-Driven:** Hooks into Gemini CLI lifecycle events (`SessionStart`, `AfterAgent`, `BeforeTool`, `Error`).

## Installation

1. Clone and link:
   ```bash
   git clone https://github.com/YOUR_USERNAME/gem-in-eer.git
   cd gem-in-eer
   gemini extensions link .
   ```
2. Setup initial RA2 sounds:
   ```powershell
   powershell.exe -File scripts/setup-audio.ps1
   ```

## Configuration

Switch packs via the CLI settings:
```bash
gemini extensions config gem-in-eer "Active Pack"
```
Or use the slash command: `/ra2:set <name>`.

## Inspiration & Attribution

- **Concept:** Based on PeonPing by [PeonPing Team](https://github.com/PeonPing).
- **Audio Assets:** Sourced from the [OpenPeon Registry](https://github.com/PeonPing/registry).
- **Ownership:** Audio files are property of their respective publishers (EA, Blizzard, Valve, etc.). Used under fair use for personal notification.

## License

MIT License. Audio files subject to their respective licenses.
