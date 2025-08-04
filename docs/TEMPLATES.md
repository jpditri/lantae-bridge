# Template Usage Guide

The Lantae Bridge system includes templates for creating consistent, well-formatted content for your campaigns.

## Available Templates

- **npc** - Non-player characters
- **location** - Places and regions
- **faction** - Organizations and groups
- **item** - Magical items and artifacts
- **lore** - World-building entries
- **player_character** - Player character sheets

## Using Templates

### Basic Usage

Create new content using the `lantae-new` command:

```bash
bin/lantae-new npc "Beverly Martinez" --campaign dresden-lite --title "The Clairvoyant Mother"
bin/lantae-new location "Crystal Spire" --campaign kepharion
bin/lantae-new faction "Order of the Rose" --campaign heretical --tagline "Defenders of the Realm"
```

### Using Data Files

For complex content, use YAML data files:

```yaml
# npc_data.yml
name: Beverly Martinez
title: The Clairvoyant Mother
campaign: dresden-lite
alignment: good
race: Human
character_class: Paranormal Investigator
level: 7
physical_description: "A tired but determined single mother..."
personality_traits:
  - name: Protective Mother
    description: Fiercely devoted to her children
  - name: Secretive
    description: Won't discuss the father of her children
```

Then create the NPC:

```bash
bin/lantae-new npc "Beverly Martinez" --data npc_data.yml
```

## Template Variables

### NPC Template

Required:
- `name` - Character name
- `campaign` - Campaign identifier

Optional:
- `title` - Character title/role
- `alignment` - Moral alignment
- `race` - Character race
- `character_class` - Character class
- `level` - Character level
- `physical_description` - Appearance
- `personality_traits` - Array of traits
- `background` - Character history
- `abilities` - Special abilities
- `relationships` - Connections to others
- `stats` - Game statistics

### Location Template

Required:
- `name` - Location name
- `campaign` - Campaign identifier

Optional:
- `region` - Larger area containing location
- `settlement_type` - City, town, village, etc.
- `overview` - General description
- `climate` - Weather patterns
- `terrain` - Geographic features
- `population_size` - Number of inhabitants
- `government_type` - Political structure
- `notable_locations` - Important places
- `npcs` - Resident characters

### Faction Template

Required:
- `name` - Organization name
- `campaign` - Campaign identifier

Optional:
- `tagline` - Brief descriptor
- `faction_type` - Guild, order, cult, etc.
- `allegiance` - Who they serve
- `influence_level` - Reach and power
- `beliefs` - Core tenets
- `members` - Notable members
- `headquarters` - Base of operations
- `resources` - Assets and capabilities

## Customizing Templates

Templates are ERB files located in `lib/templates/`. You can modify them to suit your needs:

1. Edit the `.erb` file for the template type
2. Add new variables or sections
3. Use ERB syntax for logic and formatting

### Template Helpers

Templates have access to helper methods:

- `link(text)` - Creates a wiki-link: `[[text]]`
- `tag(text)` - Creates a tag: `#text`
- `property(key, value)` - Creates a property: `key:: value`

### Example Custom Section

```erb
<% if custom_abilities && custom_abilities.any? -%>
- ### Custom Abilities
<% custom_abilities.each do |ability| -%>
	- **<%= ability[:name] %>**: <%= ability[:description] %>
	<% if ability[:cost] -%>
		- **Cost**: <%= ability[:cost] %>
	<% end -%>
<% end -%>
<% end -%>
```

## Best Practices

1. **Use Data Files**: For complex content, prepare YAML files with all data
2. **Consistent Naming**: Use lowercase with hyphens for file names
3. **Complete Required Fields**: Always provide campaign and name
4. **Link Related Content**: Use the `link()` helper for cross-references
5. **Tag Appropriately**: Include relevant tags for discoverability

## Batch Creation

Create multiple entries using shell scripts:

```bash
#!/bin/bash
# create_npcs.sh

for npc in "Beverly Martinez" "Madison Scott" "Craig Kerig"; do
  bin/lantae-new npc "$npc" --campaign dresden-lite
done
```

Or with data files:

```bash
for file in npcs/*.yml; do
  name=$(basename "$file" .yml)
  bin/lantae-new npc "$name" --data "$file"
done
```