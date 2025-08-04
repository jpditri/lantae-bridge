# Lantae Bridge

A Ruby-based bridge system for converting Lantae lore content to Logseq-compatible format.

## Overview

Lantae Bridge provides tools and templates for managing D&D campaign content in Logseq's outliner format. It handles conversion, validation, and creation of campaign content including NPCs, locations, factions, items, and lore entries.

## Features

- **Format Conversion**: Convert existing markdown files to Logseq's outliner format
- **Template System**: ERB-based templates for creating new content
- **Validation**: Ensure files are properly formatted for Logseq
- **Auto-linking**: Automatically create cross-references between entities
- **Batch Processing**: Convert entire campaigns at once
- **Command Line Tools**: Easy-to-use CLI for all operations

## Installation

```bash
gem install bundler
bundle install
```

## Usage

### Convert files to Logseq format
```bash
bin/lantae-convert path/to/file.md
bin/lantae-convert path/to/campaign/  # Convert entire directory
```

### Validate Logseq compatibility
```bash
bin/lantae-validate path/to/file.md
```

### Fix formatting issues
```bash
bin/lantae-fix path/to/file.md
```

### Create new content from templates
```bash
bin/lantae-new npc "Beverly Martinez"
bin/lantae-new location "Crystal Spire"
bin/lantae-new faction "Order of the Rose"
```

## Content Types

- **NPC**: Non-player characters with stats, descriptions, and relationships
- **Location**: Places with descriptions, connections, and encounters
- **Faction**: Organizations with members, goals, and allegiances
- **Item**: Objects with properties, descriptions, and lore
- **Lore**: World-building entries with cross-references
- **Player Character**: PC sheets with full character details

## Documentation

- [Formatting Guide](docs/FORMATTING.md) - Logseq formatting rules and best practices
- [Template Usage](docs/TEMPLATES.md) - How to use and customize templates
- [Conversion Guide](docs/CONVERSION.md) - Converting existing content

## License

MIT License - See LICENSE file for details