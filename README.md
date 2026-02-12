# Gem-in-eer 🚀

**The tools of the future!**

Gem-in-eer is a Red Alert 2 themed notification system for the Gemini CLI. It provides audio feedback for CLI events using iconic unit responses from the Command & Conquer: Red Alert 2 universe.

## Inspiration & Attribution

This project is inspired by [PeonPing](https://github.com/PeonPing/peon-ping), a notification system for Claude Code.

- **Concept:** Based on PeonPing by [PeonPing Team](https://github.com/PeonPing).
- **Audio Assets:** Sourced from the [OpenPeon Registry](https://github.com/PeonPing/registry).
- **Ownership:** Audio files are property of Electronic Arts (EA). This project uses them under fair use for personal notification purposes.

## Features

- **Iconic RA2 Sounds:** Choose between different character packs.
- **Event-Driven:** Hooks into Gemini CLI lifecycle events:
  - `SessionStart`: Battlefield control established.
  - `SessionEnd`: Battle control terminated.
  - `AfterAgent`: Objective completed.
  - `BeforeTool`: Unit acknowledging orders.
  - `Error`: Unit in distress.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/gem-in-eer.git
   cd gem-in-eer
   ```
2. Link the extension:
   ```bash
   gemini extensions link .
   ```

## Configuration

Select your preferred voice pack:
```bash
gemini extensions config gem-in-eer "Active Pack"
```
Available options: `kirov`, `engineer`, or `mashup` (default).

## Requirements

- **Windows:** Uses PowerShell and `System.Windows.Media.MediaPlayer`.
- **Gemini CLI:** A version that supports hooks and extensions.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
Audio files are subject to their respective licenses (generally CC-BY-NC-4.0 for the curated packs, but original property of EA).
