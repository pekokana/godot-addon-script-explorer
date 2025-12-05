# Script Explorer (Godot Editor Plugin)

**Displays information about the currently selected/edited GDScript in the Editor**:
- Script file name
- class_name (if present)
- extends (base class)
- Method list (with arguments)
- Top-level properties (var / const)

Tab label: **SE** (appears in the editor dock)

## Installation
1. Copy `addons/script_explorer` into your project.
2. In Godot: Project → Project Settings → Plugins → Enable "Script Explorer".

## Usage
Open a GDScript in the script editor (or select it). The SE tab will show:
- Script: `player.gd`
- Class: `Player`
- Base: `CharacterBody2D`
- Methods: `func move(dir)` ...
- Properties: `health`, `speed`, ...

## Notes
- Implemented for Godot 4.x.
- Parses `script.source_code` using RegEx; for production-level parsing consider GDScriptAnalyzer.

## License
MIT
