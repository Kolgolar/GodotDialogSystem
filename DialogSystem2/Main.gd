extends Control

export (NodePath) onready var _mouse_popup = get_node(_mouse_popup) as PopupMenu

var dialog = {}
var dialog_for_localisation = []
var file_name := ""
var directory := ""
var initial_pos = Vector2(40,40)

var max_id = 1
var start_node : StartNode

onready var error_popup = $Error
onready var error_popup_label = $Error/RichTextLabel
onready var graph_edit = $GraphEdit
onready var timer = $Timer


func _ready():
	pass
	
# ADD NEW NODE
func _on_NewNode_pressed():
	# _create_new_node("res://LineNode.tscn")
	pass
	# TODO: Autosave?
	
# SAVE 
func _on_Save_pressed(): 
	if file_name.empty():
		$ConfirmationDialog.popup()
		return
	
	dialog.clear()
	for node in get_tree().get_nodes_in_group("graph_nodes"):
		dialog.merge(node.gen_base_data())
		dialog[str(node.id)].merge(node.gen_data($GraphEdit))

	# print(dialog)
	save_dialog(directory, file_name)
	

func _create_graph_node(scene : String, pos := Vector2.ZERO, _is_start_node := false, set_to_defaults := true) -> GraphNode:
	var node = load(scene).instance()
	graph_edit.add_child(node)
	if node is StartNode:
		$MousePopup.set_item_disabled(0, true)
		node.connect("on_delete", self, "_on_StartNode_delete")
		start_node = node
	if set_to_defaults:
		_set_new_node_params(node, pos, _is_start_node)
		
	return node


func _set_new_node_params(node : GraphNode, pos : Vector2, _is_start_node := false) -> void:
	if node is StartNode:
		node.id = 0
	else:
		max_id += 1
		node.id = max_id
	node.offset = graph_edit.scroll_offset + pos
	initial_pos = node.offset



func _validation() -> int:
	error_popup_label.clear()
	var err := OK
	if not start_node:
		show_popup_error("Add start node to the graph!")
		err = ERR_DOES_NOT_EXIST
	for node in get_tree().get_nodes_in_group("graph_nodes"):
		match node.type:
			"LINE":
				pass
			"CONDITION":
				if node.condition_var.text.empty():
					err = ERR_INVALID_DATA
					show_popup_error("No condition variable at node '" + node.title + "'")
			"START":
				var connected := false
				for connection in graph_edit.get_connection_list():
					print(connection)
					if connection["from"] == node.name:
						connected = true
						break
				if not connected:
					show_popup_error("Start node should have at least 1 connection!")
					err = ERR_DOES_NOT_EXIST
			"SETTER":
				if node.var_name.text.empty() or node.var_value.text.empty():
					show_popup_error("Setter node '" + node.title + "' has empty parameters!")
					err = ERR_INVALID_DATA
			"CALLER":
				if node.var_name.text.empty():
					show_popup_error("Caller node '" + node.title + "' has empty function name!")
					err = ERR_INVALID_DATA
			_:
				err = ERR_INVALID_DATA
				show_popup_error("Unknown node type " + str(node.type) + ". Can't make validation.")
	return err


func show_popup_error(error_text : String) -> void:
	var time = OS.get_time()
	error_popup_label.text += "\n[{0}:{1}:{2}".format([time["hour"], time["minute"], time["second"]]) + "]  " + error_text
	error_popup.popup()


func save_dialog(path, fn):	
	# save file
	var err = _validation()
	if fn.empty():
		# printerr("File name is empty!")
		return
	var file = File.new()
	# file_path = file_path
	if not ".json" in fn:
		fn += ".json"
	
	var data = {}
	data["CONFIG"] = {"max_id" : max_id}
	data["TIMELINE"] = dialog
	file.open(path + fn, File.WRITE)
	file.store_line(to_json(data))
	
	file.close()
	# $FileName.text = fn
	
	if err != OK:
		printerr("Error on validation!")
		show_popup_error("Saving complete, but you must resolve errors!")


	$VBoxContainer/HBoxContainer/Notification.visible = true
	timer.start()
	yield(timer, "timeout")
	$VBoxContainer/HBoxContainer/Notification.visible = false
	

func load_save(path, fn):
	if path.empty() or fn.empty():
		print("File not found!")
		return

	_clear()
	_set_filename(fn)
	var file = File.new()

	file.open(path + fn, File.READ)
	var data = parse_json(file.get_as_text())
	file.close()
	var timeline = data["TIMELINE"]
	var config = data["CONFIG"]

	max_id = config["max_id"]

	var graph_names := {}

	for graph_node in timeline:
		var node_scene_path
		match timeline[graph_node]["type"]:
			"LINE":
				node_scene_path = "res://LineNode.tscn"
			"CONDITION":
				node_scene_path = "res://ConditionNode.tscn"
			"START":
				node_scene_path = "res://StartNode.tscn"
			"SETTER":
				node_scene_path = "res://SetterNode.tscn"
			"CALLER":
				node_scene_path = "res://CallerNode.tscn"
			_:
				printerr("Unknown node type!")
		# node = node.instance()
		var node = _create_graph_node(node_scene_path, Vector2.ZERO, false, false)
		# graph_edit.add_child(node)
		node.set_base_data($GraphEdit, timeline[graph_node], graph_node)
		node.set_data($GraphEdit, timeline[graph_node], graph_node)
		graph_names[graph_node] = node.name

	for graph_node in timeline:
		for tag in timeline[graph_node]:
			var from_port_num := -1
			match tag:
				"go_to":
					from_port_num = 0
				"go_to_true":
					from_port_num = 0
				"go_to_false":
					from_port_num = 1
				_:
					pass
			if from_port_num >= 0:
				var go_to_count = 0
				for go_to in timeline[graph_node][tag]: # get each in array
					graph_edit.connect_node(graph_names[graph_node], from_port_num, graph_names[timeline[graph_node][tag][go_to_count]], 0)
					go_to_count += 1


func _set_filename(new_name : String) -> void:
	$FileName.text = new_name
	file_name = new_name


func _clear() -> void:
	for node in get_tree().get_nodes_in_group("graph_nodes"):
		node.delete()
	graph_edit.clear_connections()
	_set_filename("")


func _call_mouse_popup() -> void:
	_mouse_popup.rect_global_position = get_global_mouse_position()
	_mouse_popup.popup()


func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	graph_edit.connect_node(from, from_slot, to, to_slot)


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	graph_edit.disconnect_node(from, from_slot, to, to_slot)


func _on_GraphEdit_gui_input(event):
	if Input.is_action_pressed("right_click"):
		_call_mouse_popup()
	

func _on_OpenNew_pressed():
	$DialoguesSearcher.popup()


func _on_SaveAs_pressed():
	$ConfirmationDialog.popup()


func _on_ConfirmationDialog_save_dialog_as(fn : String):
	_set_filename(fn)
	_on_Save_pressed()
	save_dialog(directory, fn)


func _on_DialoguesSearcher_directory_updated(path : String):
	directory = path


func _on_Clear_pressed():
	_clear()


func _on_MousePopup_id_pressed(id:int):
	match id:
		0:
			_create_graph_node("res://StartNode.tscn", _mouse_popup.rect_global_position, true)
		1:
			_create_graph_node("res://LineNode.tscn", _mouse_popup.rect_global_position)
		2:
			_create_graph_node("res://ConditionNode.tscn", _mouse_popup.rect_global_position)
		3:
			_create_graph_node("res://SetterNode.tscn", _mouse_popup.rect_global_position)
		4:
			_create_graph_node("res://CallerNode.tscn", _mouse_popup.rect_global_position)
		_:
			printerr("Unknown id!")

func _on_StartNode_delete():
	$MousePopup.set_item_disabled(0, false)