extends GraphNode

class_name DefaultNode

export(NodePath) onready var main = get_node(main) as VBoxContainer
export(NodePath) onready var node_title =  get_node(node_title) as LineEdit
export(NodePath) onready var comment_box = get_node(comment_box) as HBoxContainer

onready var type := "DEFAULT"

var id : int
var short_title := ""

signal name_changed


func _ready():
	call_deferred("_update_title_text", "New")


func set_data(graph_edit : GraphEdit, data : Dictionary) -> void:
	pass


func gen_data(graph_edit : GraphEdit) -> Dictionary:
	return {}


func _update_title_text(new_text : String) -> void:
	title = type + " " + new_text
	short_title = new_text


func _on_Title_text_changed(new_text : String):
	_update_title_text(new_text)


func _on_GraphNode_resize_request(new_minsize):
	rect_size = new_minsize


func _on_GraphNode_close_request():
	# # if last node is deleted, replace that node index and name
	# if get_parent().get_parent().node_index == (int(self.name.lstrip("Node "))):
	# 	get_parent().get_parent().node_index -= 1
	queue_free()
