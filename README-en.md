# Script Explorer (Godot Editor Plugin) Ver1.1

## Displays information about the currently selected/edited GDScript in the Editor**:

1. Open any script in the Godot Script Editor  
2. A dock labeled **“SE”** will appear on the right  
3. The dock shows:
   - Script name  
   - Class / Base class  
   - Method list  
   - Property list  
   - Signal list  

4. Click a method → cursor jumps to its source line

5. Click a Property → cursor jumps to its source line

6. Click a Signal → cursor jumps to its source line

## Installation
1. Copy `addons/script_explorer` into your project.
2. In Godot: Project → Project Settings → Plugins → Enable "Script Explorer".


## Notes
- Implemented for Godot 4.x.
- Parses `script.source_code` using RegEx; for production-level parsing consider GDScriptAnalyzer.


## Future Enhancements (planned)

- Search bar for filtering methods
- Real-time updates while editing
- Collapsible sections  
- Grouping private/public methods  
- Two-column tree with type info  


## License

MIT License
