# Gem-in-eer 🚀

**The tools of the future!**

Gem-in-eer is a themed notification system for the Gemini CLI. It provides audio feedback for CLI events using a curated set of unit responses and environmental sounds, while allowing you to tap into the entire [PeonPing](https://github.com/PeonPing/peon-ping) sound ecosystem.

## Features

- **Themed Audio:** Comes with a balanced "mashup" pack of engineering and tactical responses.
- **PeonPing Integration:** Access any pack from the [OpenPeon Registry](https://github.com/PeonPing/registry) (Warcraft, StarCraft, Portal, etc.).
- **Slash Commands:**
  - `/gem-in-eer:list`: Browse all available sound packs.
  - `/gem-in-eer:set <pack_name>`: Download and prepare a specific pack.
  - `/gem-in-eer:mashup`: Restore the original sound experience.
- **Event-Driven:** Hooks into Gemini CLI lifecycle events (`SessionStart`, `AfterAgent`, `BeforeTool`, `Error`).

## Installation

Install directly via the Gemini CLI:
```bash
gemini extensions install https://github.com/genneth/gem-in-eer
```
*Note: Audio assets will be downloaded automatically upon the first run.*

## Configuration

Switch packs via the CLI settings:
```bash
gemini extensions config gem-in-eer "Active Pack"
```
Or use the slash command: `/gem-in-eer:set <name>`.

## Inspiration & Attribution

This project is a tribute to the classic real-time strategy aesthetics and is heavily inspired by [PeonPing](https://github.com/PeonPing/peon-ping).

- **Concept:** Based on PeonPing by [PeonPing Team](https://github.com/PeonPing).
- **Audio Assets:** Sourced from the [OpenPeon Registry](https://github.com/PeonPing/registry).
- **Aesthetic:** Inspired by *Command & Conquer: Red Alert 2* (Electronic Arts).

## License

MIT License. Audio files subject to their respective licenses.
