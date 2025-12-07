# Script Explorer (Godot Editor Plugin) Ver1.2

## Displays information about the currently selected / edited GDScript in the editor

1. Open any GDScript in the Godot script editor  
2. A dock labeled **"SE"** will appear on the right side  
3. The dock displays the following information:
   - Script name
   - Class / Base class
   - Method list
   - Property list
   - Signal list

4. Click a method → the cursor jumps to the corresponding source line  
5. Click a property → the cursor jumps to the corresponding source line  
6. Click a signal → the cursor jumps to the corresponding source line  
7. You can switch the dock contents into a floating window.

---

### How to use the Floating Window

Press the **◱ button** at the top-right of the dock to open the floating view.

To close the floating view, simply click the window’s close button.

---

### Features of the Floating Window

- View script information in a separate window independent from the editor  
- Can be freely positioned anywhere  
- Resizable  
- Same content and behavior as the dock version  
- Switch back and forth with a single click  

---

## Installation

1. Copy the folder:  
   `addons/script_explorer`  
   into your project  
2. In Godot, go to:  
   **Project → Project Settings → Plugins → Script Explorer**, and enable it

---

## Notes

- Implemented for Godot 4.x  
- Script parsing is performed via regular expressions on `script.source_code`  
  (For production-grade script analysis, consider GDScriptAnalyzer)  
- The floating window is dynamically added to `EditorBaseControl` via EditorPlugin and managed as an independent `Window` node

---

## Planned Feature Enhancements

- Search bar for filtering methods  
- Real-time updates during editing  
- Collapsible sections  
- Grouping private/public methods  
- Two-column tree with type information  

---

## License

MIT License
