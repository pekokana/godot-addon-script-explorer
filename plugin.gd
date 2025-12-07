@tool
extends EditorPlugin

var DockScene := preload("res://addons/script_explorer/dock.tscn")

var dock
var floating_window: Window = null
var floating_dock: Node = null

var methods_data := []
var properties_data := []
var signal_data := []


# ---------------------------------------------------------
# Plugin lifecycle
# ---------------------------------------------------------
func _enter_tree():
	# Dock をロードして右側へ配置
	dock = DockScene.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)

	# Dock ready 待ち
	dock.ready.connect(_on_dock_ready)

	# スクリプト切替イベント
	var script_editor = get_editor_interface().get_script_editor()
	script_editor.editor_script_changed.connect(_on_script_changed)

	# Dock 側のシグナル接続
	dock.method_selected.connect(_on_method_selected)
	dock.properties_selected.connect(_on_properties_selected)
	dock.signal_selected.connect(_on_signal_selected)
	dock.toggle_window_requested.connect(_on_window_toggle)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.free()

	if floating_window:
		floating_window.queue_free()


func _on_dock_ready():
	# 念のため再接続（重複接続防止済み）
	if not dock.is_connected("method_selected", _on_method_selected):
		dock.method_selected.connect(_on_method_selected)


# ---------------------------------------------------------
# Script update / parsing
# ---------------------------------------------------------
func _on_script_changed(script):
	if script == null:
		return

	var info = _parse_script(script)

	methods_data = info["methods"]
	properties_data = info["properties"]
	signal_data = info["signals"]

	# Dock 更新
	if dock and dock.has_method("update_info"):
		dock.update_info(info)

	# フロート Dock 更新
	if floating_dock and floating_dock.has_method("update_info"):
		floating_dock.update_info(info)


# スクリプト解析
func _parse_script(script: GDScript) -> Dictionary:
	var info := {
		"script_name": script.resource_path.get_file(),
		"class_name": "",
		"base_class": "",
		"methods": [],
		"properties": [],
		"signals": [],
	}

	var code = script.source_code

	# class_name
	var r_class := RegEx.new()
	r_class.compile(r"(?m)^class_name\s+([A-Za-z0-9_]+)")
	var m = r_class.search(code)
	if m:
		info["class_name"] = m.get_string(1)

	# extends
	var r_ext := RegEx.new()
	r_ext.compile(r"(?m)^extends\s+([A-Za-z0-9_\.]+)")
	m = r_ext.search(code)
	if m:
		info["base_class"] = m.get_string(1)

	# methods
	var r_func := RegEx.new()
	r_func.compile(r"func\s+([A-Za-z0-9_]+)\s*\(([^)]*)\)")
	for match in r_func.search_all(code):
		var line = code.substr(0, match.get_start()).count("\n") + 1
		info["methods"].append({
			"name": match.get_string(1),
			"args": match.get_string(2).strip_edges(),
			"line": line,
		})

	# properties
	var r_var := RegEx.new()
	r_var.compile(r"(?m)^(?:var|const)\s+([A-Za-z0-9_]+)")
	for match in r_var.search_all(code):
		var line = code.substr(0, match.get_start()).count("\n") + 1
		info["properties"].append({
			"name": match.get_string(1),
			"line": line,
		})

	# signals
	var r_signal := RegEx.new()
	r_signal.compile(r"signal\s+([A-Za-z0-9_]+)")
	for match in r_signal.search_all(code):
		var line = code.substr(0, match.get_start()).count("\n") + 1
		info["signals"].append({
			"name": match.get_string(1),
			"line": line,
		})

	return info


# ---------------------------------------------------------
# Line jump handlers
# ---------------------------------------------------------
func _on_method_selected(index: int):
	if index < 0 or index >= methods_data.size():
		return
	var line = methods_data[index]["line"]
	_jump_to_line(line)

func _on_properties_selected(index: int):
	if index < 0 or index >= properties_data.size():
		return
	_jump_to_line(properties_data[index]["line"])

func _on_signal_selected(index: int):
	if index < 0 or index >= signal_data.size():
		return
	_jump_to_line(signal_data[index]["line"])

func _jump_to_line(line: int):
	var editor = get_editor_interface().get_script_editor()
	editor.goto_line(line - 1)


# ---------------------------------------------------------
# Floating window
# ---------------------------------------------------------
func _on_window_toggle(active: bool):
	if active:
		_open_floating_window()
	else:
		_close_floating_window()


func _open_floating_window():
	if floating_window:
		floating_window.popup()
		return

	# Window 作成
	floating_window = Window.new()
	floating_window.title = "Script Explorer"
	floating_window.size = Vector2(420, 650)
	floating_window.min_size = Vector2(350, 500)
	floating_window.close_requested.connect(_on_floating_window_close)

	# Editor 画面に追加
	var parent = get_editor_interface().get_base_control()
	parent.add_child(floating_window)

	# Dock UI を複製
	floating_dock = DockScene.instantiate()
	floating_dock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	floating_dock.size_flags_vertical = Control.SIZE_EXPAND_FILL
	floating_window.add_child(floating_dock)

	# ツリーを縦伸びさせる
	_fix_tree_vertical_expand(floating_dock)

	# シグナル接続（Dock と同じ動き）
	floating_dock.method_selected.connect(_on_method_selected)
	floating_dock.properties_selected.connect(_on_properties_selected)
	floating_dock.signal_selected.connect(_on_signal_selected)

	# 現在スクリプト情報を反映
	var script = get_editor_interface().get_script_editor().get_current_script()
	if script:
		floating_dock.update_info(_parse_script(script))

	# 中央に表示
	floating_window.popup_centered_ratio(0.25)


func _on_floating_window_close():
	_close_floating_window()

	# Dock のトグルも OFF に戻す
	if dock and dock.has_method("set_window_toggle_state"):
		dock.set_window_toggle_state(false)


func _close_floating_window():
	if floating_dock:
		floating_dock.queue_free()
		floating_dock = null

	if floating_window:
		floating_window.queue_free()
		floating_window = null


# ---------------------------------------------------------
# Helpers
# ---------------------------------------------------------
func _fix_tree_vertical_expand(node: Node):
	for c in node.get_children():
		if c is Tree:
			c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			c.size_flags_vertical = Control.SIZE_EXPAND_FILL
		else:
			_fix_tree_vertical_expand(c)
