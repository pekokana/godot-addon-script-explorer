@tool
extends VBoxContainer

@onready var lbl_script = $ScriptLabel
@onready var lbl_class = $ClassLabel
@onready var lbl_base = $BaseLabel
@onready var methods_tree = $MethodsTree
@onready var props_tree = $PropertiesTree

func update_info(info: Dictionary):
	lbl_script.text = "Script: %s" % info["script_name"]
	lbl_class.text = "Class: %s" % info["class_name"]
	lbl_base.text = "Base: %s" % info["base_class"]

	# --- Methods ---
	methods_tree.clear()
	var root = methods_tree.create_item()
	for m in info["methods"]:
		var item = methods_tree.create_item(root)
		item.set_text(0, "%s(%s)" % [m["name"], m["args"]])

	# --- Properties ---
	props_tree.clear()
	var root2 = props_tree.create_item()
	for p in info["properties"]:
		var item2 = props_tree.create_item(root2)
		item2.set_text(0, p)
