@tool
extends VBoxContainer

@onready var lbl_script = $HBoxContainer/ScriptLabel
@onready var window_toggle = $HBoxContainer/WindowToggleButton
@onready var lbl_class = $ClassLabel
@onready var lbl_base = $BaseLabel
@onready var methods_tree = $MethodsTree
@onready var props_tree = $PropertiesTree
@onready var signals_tree = $SignalsTree

var last_methods := []
var last_properties := []
var last_signal := []

signal method_selected(index: int)
signal properties_selected(index: int)
signal signal_selected(index: int)
signal toggle_window_requested(active: bool)

func _ready():
	#print("dock.gd READY — signals:", get_signal_list())
	
	methods_tree.columns = 2
	methods_tree.set_column_title(0, "Method")
	methods_tree.set_column_title(1, "Args")
	methods_tree.connect("cell_selected", Callable(self, "_on_method_clicked"))
	props_tree.connect("cell_selected", Callable(self, "_on_properties_clicked"))
	signals_tree.connect("cell_selected", Callable(self, "_on_signal_clicked"))

	window_toggle.toggle_mode = true
	window_toggle.toggled.connect(_on_window_toggle)

func _on_window_toggle(active: bool):
	emit_signal("toggle_window_requested", active)

func _on_method_clicked():
	var item = methods_tree.get_selected()
	if not item:
		return

	# index を取得
	var index := int(item.get_index())
	emit_signal("method_selected", index)

func _on_properties_clicked():
	var item = props_tree.get_selected()
	if not item:
		return

	# index を取得
	var index := int(item.get_index())
	emit_signal("properties_selected", index)

func _on_signal_clicked():
	var item = signals_tree.get_selected()
	if not item:
		return

	# index を取得
	var index := int(item.get_index())
	emit_signal("signal_selected", index)


func update_info(info: Dictionary):
	lbl_script.text = "Script >  %s" % info["script_name"]
	lbl_class.text = "Class >  %s" % info["class_name"]
	lbl_base.text = "Base >  %s" % info["base_class"]

	# --- Methods ---
	methods_tree.clear()
	var root = methods_tree.create_item()
	last_methods.clear()

	for m in info["methods"]:
		var item = methods_tree.create_item(root)
		item.set_text(0, m["name"])
		item.set_text(1, m["args"])

		# private を薄く
		if m["name"].begins_with("_"):
			item.set_custom_color(0, Color(1,1,1,0.4))
			item.set_custom_color(1, Color(1,1,1,0.4))

		last_methods.append(m)

	# --- Properties ---
	props_tree.clear()
	var root2 = props_tree.create_item()
	last_properties.clear()
	
	for p in info["properties"]:
		var item2 = props_tree.create_item(root2)
		item2.set_text(0, p["name"])
		last_properties.append(p)

	# --- Signals ---
	signals_tree.clear()
	var root3 = signals_tree.create_item()
	last_signal.clear()
	
	for s in info["signals"]:
		var item3 = signals_tree.create_item(root3)
		item3.set_text(0, s["name"])
		last_signal.append(s)

func set_window_toggle_state(state: bool) -> void:
	if not window_toggle:
		return

	# ToggleButton の場合（最も正しい動作）
	if window_toggle is Button:
		window_toggle.set_pressed_no_signal(state)
		return

	# 代替：ボタンにメソッドがあれば使う
	if window_toggle.has_method("set_pressed_no_signal"):
		window_toggle.set_pressed_no_signal(state)
		return

	# 最後の手段：プロパティを直接セット（安全な Object.set）
	window_toggle.set("pressed", state)
