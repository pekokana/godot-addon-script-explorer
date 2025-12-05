@tool
extends EditorPlugin

var dock

func _enter_tree():
	# Dock を読み込み
	dock = load("res://addons/script_explorer/dock.tscn").instantiate()

	# エディタ右側に追加
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)

	# スクリプト切り替えイベントを監視
	var script_editor = get_editor_interface().get_script_editor()
	script_editor.connect("editor_script_changed", Callable(self, "_on_script_changed"))

func _exit_tree():
	# EditorPlugin の API: 追加した Dock を削除する (Godot 4 系)
	# -> remove_control_from_docks() を直接使う
	remove_control_from_docks(dock)
	# free は queue_free() でも可。Editor 上だと queue_free() が安全な場合もあるが、ここでは free() でOK
	dock.free()

func _on_script_changed(script):
	#var script = get_editor_interface().get_script_editor().get_current_script()
	if script == null:
		return

	var info := _parse_script(script)
	# dock 側に update_info() が実装されている想定
	if dock and dock.has_method("update_info"):
		dock.update_info(info)

func _parse_script(script: GDScript) -> Dictionary:
	var info := {
		"script_name": "", 
		"class_name": "",
		"base_class": "",
		"methods": [],
		"properties": [],
	}

	var code = script.source_code

	# --- script_name
	info["script_name"] = script.resource_path.get_file()

	# --- class_name ---
	var regex_class := RegEx.new()
	regex_class.compile(r"(?m)^class_name\s+([A-Za-z0-9_]+)")
	var m = regex_class.search(code)
	if m:
		info["class_name"] = m.get_string(1)

	# --- extends ---
	var regex_extends := RegEx.new()
	regex_extends.compile(r"(?m)^extends\s+([A-Za-z0-9_\.]+)")
	m = regex_extends.search(code)
	if m:
		info["base_class"] = m.get_string(1)

	# --- methods ---
	var regex_func := RegEx.new()
	regex_func.compile(r"func\s+([A-Za-z0-9_]+)\s*\(([^)]*)\)")
	for match in regex_func.search_all(code):
		info["methods"].append({
			"name": match.get_string(1),
			"args": match.get_string(2).strip_edges(),
		})

	# --- var / const ---
	var regex_var := RegEx.new()
	regex_var.compile(r"(?m)^(?:var|const)\s+([A-Za-z0-9_]+)")
	for match in regex_var.search_all(code):
		info["properties"].append(match.get_string(1))

	return info
