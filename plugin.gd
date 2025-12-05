@tool
extends EditorPlugin

var DockScene := preload("res://addons/script_explorer/dock.tscn")
var dock
var methods_data := [] 
var properties_data := []
var signal_data := []

func _ready():
	if dock.has_signal("method_selected"):
		var c = Callable(self, "_on_method_selected")
		if not dock.is_connected("method_selected", c):
			dock.connect("method_selected", c)

	if dock.has_signal("properties_selected"):
		var c = Callable(self, "_on_properties_selected")
		if not dock.is_connected("properties_selected", c):
			dock.connect("properties_selected", c)

	if dock.has_signal("signal_selected"):
		var c = Callable(self, "_on_signal_selected")
		if not dock.is_connected("signal_selected", c):
			dock.connect("signal_selected", c)

func _enter_tree():
	# Dock を読み込み
	dock = DockScene.instantiate()

	# エディタ右側に追加
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)

	# ready 待ちして connect する
	dock.ready.connect(_on_dock_ready)

	# スクリプト切り替えイベントを監視
	var script_editor = get_editor_interface().get_script_editor()
	script_editor.connect("editor_script_changed", Callable(self, "_on_script_changed"))

	dock.method_selected.connect(_on_method_selected)

func _on_dock_ready():
	# ここで初めてシグナルが存在するので connect OK
	if dock.has_signal("method_selected"):
		dock.method_selected.connect(_on_method_selected)
	else:
		push_warning("dock has no signal 'method_selected'")

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
	
	methods_data = info["methods"] 
	properties_data = info["properties"]
	signal_data = info["signals"]
	# dock 側に update_info() が実装されている想定
	if dock and dock.has_method("update_info"):
		dock.update_info(info)

func _on_method_selected(index):
	if index < 0 or index >= methods_data.size():
		return

	var line = methods_data[index]["line"]
	var editor = get_editor_interface().get_script_editor()
	editor.goto_line(line - 1)

func _on_properties_selected(index):
	if index < 0 or index >= properties_data.size():
		return

	var line = properties_data[index]["line"]
	var editor = get_editor_interface().get_script_editor()
	editor.goto_line(line - 1)

func _on_signal_selected(index):
	if index < 0 or index >= signal_data.size():
		return

	var line = signal_data[index]["line"]
	var editor = get_editor_interface().get_script_editor()
	editor.goto_line(line - 1)


func _parse_script(script: GDScript) -> Dictionary:
	var info := {
		"script_name": "", 
		"class_name": "",
		"base_class": "",
		"methods": [],
		"properties": [],
		"signals": [],
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
		var line = code.substr(0, match.get_start()).count("\n") + 1
		info["methods"].append({
			"name": match.get_string(1),
			"args": match.get_string(2).strip_edges(),
			"line": line,
		})

	# --- var / const ---
	var regex_var := RegEx.new()
	regex_var.compile(r"(?m)^(?:var|const)\s+([A-Za-z0-9_]+)")
	for match in regex_var.search_all(code):
		var line = code.substr(0, match.get_start()).count("\n") + 1
		info["properties"].append({
			"name": match.get_string(1),
			"line": line,
		})

	# Signals --------------------------------------------------
	var regex_signal := RegEx.new()
	regex_signal.compile(r"signal\s+([A-Za-z0-9_]+)")
	for match in regex_signal.search_all(code):
		var line = code.substr(0, match.get_start()).count("\n") + 1
		info["signals"].append({
			"name": match.get_string(1),
			"line": line,
		})

	return info
