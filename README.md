# Gem-in-eer 🚀

**The tools of the future!**

Gem-in-eer is a sound notification system for the Gemini CLI. It allows you to tap into the entire [PeonPing](https://github.com/PeonPing/peon-ping) sound ecosystem to get audio feedback for CLI events.

## Features

- **PeonPing Integration:** Access any pack from the [OpenPeon Registry](https://github.com/PeonPing/registry) (Warcraft, StarCraft, Red Alert, Portal, etc.).
- **Slash Commands:**
  - `/gem-in-eer:list`: Browse all available sound packs.
  - `/gem-in-eer:set <pack_name>`: Download and set a specific pack (e.g., `/gem-in-eer:set ra2_kirov`).
- **Event-Driven:** Hooks into Gemini CLI lifecycle events (`SessionStart`, `AfterAgent`, `BeforeTool`, `Error`).

## Installation

Install directly via the Gemini CLI:
```bash
gemini extensions install https://github.com/genneth/gem-in-eer
```

After installation, use the slash command to download your first sound pack:
```bash
/gem-in-eer:set ra2_kirov
```

## Configuration

Switch packs via the CLI settings:
```bash
gemini extensions config gem-in-eer "Active Pack"
```
Or use the slash command: `/gem-in-eer:set <name>`.

## Inspiration & Attribution

This project is a tribute to classic real-time strategy aesthetics and is heavily inspired by [PeonPing](https://github.com/PeonPing/peon-ping).

- **Concept:** Based on PeonPing by [PeonPing Team](https://github.com/PeonPing).
- **Audio Assets:** Sourced from the [OpenPeon Registry](https://github.com/PeonPing/registry).
- **Aesthetic:** Inspired by *Command & Conquer: Red Alert 2* (Electronic Arts).

## License

MIT License. Audio files subject to their respective licenses.
