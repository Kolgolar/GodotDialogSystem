extends GraphNode

class_name DefaultNode

onready var main = $HBoxContainer/MainColumn
onready var node_title =  $HBoxContainer/MainColumn/Title/Title
onready var comment_box = $HBoxContainer/MainColumn/Comment

onready var type := "DEFAULT"

var id : int
var short_title := ""

signal name_changed


func _ready():
	# call_deferred("_update_title_text", "New")
	pass


func set_base_data(graph_edit : GraphEdit, data : Dictionary, id_name : String) -> void:
	id = int(id_name)
	offset.x  = data["offset_x"]
	offset.y = data["offset_y"]
	type = data["type"]
	_update_title_text(data["title"])


func gen_base_data() -> Dictionary:
	var data := {}
	# data["id"] = id
	data["type"] = type
	data["title"] = short_title
	data["offset_x"] = offset.x
	data["offset_y"] = offset.y
	return {str(id) : data}


func set_data(graph_edit : GraphEdit, data : Dictionary, id_name : String) -> void:
	pass


func gen_data(graph_edit : GraphEdit) -> Dictionary:
	return {}


func delete() -> void:
	_on_GraphNode_close_request()


func _update_title_text(new_text : String, update_node_text := true) -> void:
	title = type + " " + new_text
	short_title = new_text
	print(short_title)
	if update_node_text:
		node_title.text = short_title


func _on_Title_text_changed(new_text : String):
	_update_title_text(new_text, false)


func _on_GraphNode_resize_request(new_minsize):
	rect_size = new_minsize


func _on_GraphNode_close_request():
	queue_free()
