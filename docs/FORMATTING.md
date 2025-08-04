# Logseq Formatting Guide

This guide explains the proper formatting rules for Logseq-compatible markdown files in the Lantae lore system.

## Core Principles

Logseq uses an outliner-based approach where every line is a block. This differs from traditional markdown in several key ways:

### 1. Everything is a Bullet

In Logseq, all content should be in bullet format:

```markdown
- This is correct
- Every line starts with a dash
	- Nested content uses tabs
	- Like this
```

### 2. Properties

Properties use double colons and must be on bullet lines:

```markdown
title:: Character Name
type:: npc
campaign:: dresden-lite
tags:: #urban-fantasy #npc #wizard
```

### 3. Headers in Bullets

Headers must be part of the bullet structure:

```markdown
- # Main Header
- ## Subheader
	- Content under subheader
- ### Another Section
```

## Content Structure

### NPCs

```markdown
title:: Beverly Martinez - The Clairvoyant Mother
type:: npc
campaign:: dresden-lite
tags:: #npc #psychic #single-mother

- # Beverly Martinez
- ## The Clairvoyant Mother

- ### Physical Description
	- Description text here
	- **Notable Features**: Special characteristics

- ### Personality Traits
	- **Trait Name**: Description
	- **Another Trait**: Description
```

### Locations

```markdown
title:: Crystal Spire
type:: location
campaign:: kepharion
tags:: #location #magical #tower

- # Crystal Spire

- ### Overview
	- General description

- ### Geography
	- **Climate**: Temperate
	- **Terrain**: Mountainous
```

## Cross-References

Use double brackets for internal links:

```markdown
- The character lives in [[Salem]]
- Works with [[Beverly Martinez]]
- Member of the [[Order of Krolus]]
```

## Tags

Tags use the hashtag format:

```markdown
- Single tag: #wizard
- Multiple tags: #urban-fantasy #boston #magic
- Compound tags: #player-character
```

## Common Mistakes to Avoid

### Wrong: Headers without bullets
```markdown
## This is wrong
Content here
```

### Right: Headers with bullets
```markdown
- ## This is correct
	- Content here
```

### Wrong: Properties with single colon
```markdown
title: Wrong Format
```

### Right: Properties with double colon
```markdown
title:: Correct Format
```

### Wrong: Non-bulleted content
```markdown
This paragraph has no bullet point.
It will not work well in Logseq.
```

### Right: Bulleted content
```markdown
- This paragraph is properly formatted
- Each line has its own bullet
	- And can be nested as needed
```

## Best Practices

1. **Start with Properties**: Always put properties at the top of the file
2. **Use Consistent Indentation**: Use tabs for nesting, not spaces
3. **One Thought Per Bullet**: Break content into discrete blocks
4. **Link Liberally**: Create connections between related content
5. **Tag Systematically**: Use consistent tag naming conventions

## Validation

Use the `lantae-validate` tool to check your files:

```bash
bin/lantae-validate file path/to/file.md
bin/lantae-validate directory path/to/campaign/
```

This will identify common formatting issues and suggest fixes.