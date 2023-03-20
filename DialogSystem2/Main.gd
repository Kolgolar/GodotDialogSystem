extends Control

var dialog = {}
var dialog_for_localisation = []
var file_name := ""
var directory := ""
var initial_pos = Vector2(40,40)

var max_id = 0

onready var graph_edit = $GraphEdit
onready var timer = $Timer


func _ready():
	pass
	
# ADD NEW NODE
func _on_NewNode_pressed():
	var node = load("res://LineNode.tscn").instance()
	graph_edit.add_child(node)
	initial_pos = node.offset
	max_id += 1
	node.id = max_id
	# TODO: Autosave?
	
# SAVE 
func _on_Save_pressed(): 
	if file_name.empty():
		$ConfirmationDialog.popup()
		return
	
	dialog.clear()
	for node in get_tree().get_nodes_in_group("graph_nodes"):
		dialog.merge(node.gen_data($GraphEdit))

	# print(dialog)
	save_dialog(directory, file_name)
	
	
func save_dialog(path, fn):	
	# save file
	if fn.empty():
		print("File name empty!")
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
	$FileName.text = fn
	
	$VBoxContainer/HBoxContainer/Notification.visible = true
	timer.start()
	yield(timer, "timeout")
	$VBoxContainer/HBoxContainer/Notification.visible = false
	

func load_save(path, fn):
	if path.empty() or fn.empty():
		print("File not found!")
		return

	file_name = fn
	$FileName.text = fn
	_clear()
	var file = File.new()

	file.open(path + fn, File.READ)
	var data = parse_json(file.get_as_text())
	file.close()
	var timeline = data["TIMELINE"]
	var config = data["CONFIG"]

	max_id = config["max_id"]

	var graph_names := {}

	for graph_node in timeline:
		var node
		match timeline[graph_node]["type"]:
			"LINE":
				node = load("res://LineNode.tscn")
			_:
				printerr("Unknown node type!")
		node = node.instance()
		graph_edit.add_child(node)
		node.set_data($GraphEdit, timeline[graph_node])
		graph_names[graph_node] = node.name

	for graph_node in timeline:
		if "go_to" in timeline[graph_node]:		
			var go_to_count = 0
			for go_to in timeline[graph_node]["go_to"]: # get each in array
				graph_edit.connect_node(graph_names[graph_node], 0, graph_names[timeline[graph_node]["go_to"][go_to_count]], 0)
				go_to_count += 1



func _clear() -> void:
	for node in get_tree().get_nodes_in_group("graph_nodes"):
		node.queue_free()
	graph_edit.clear_connections()

	
# connect nodes
func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	graph_edit.connect_node(from, from_slot, to, to_slot)


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	graph_edit.disconnect_node(from, from_slot, to, to_slot)


func _on_GraphEdit_gui_input(event):
	if Input.is_action_pressed("right_click"):
		#  _on_Button_pressed()
		pass
	elif event is InputEventMouseButton and event.doubleclick:
	#   _on_NewOption_pressed()
		pass
	elif Input.is_action_pressed("save"):
		_on_Save_pressed()
	elif Input.is_action_just_pressed("new_option"):
		# _on_NewOption_pressed()
		pass
	

func _on_OpenNew_pressed():
	$DialoguesSearcher.popup()


func _on_SaveAs_pressed():
	$ConfirmationDialog.popup()


func _on_ConfirmationDialog_save_dialog_as(fn : String):
	file_name = fn
	_on_Save_pressed()
	save_dialog(directory, fn)


func _on_DialoguesSearcher_directory_updated(path : String):
	directory = path


func _on_Clear_pressed():
	_clear()
