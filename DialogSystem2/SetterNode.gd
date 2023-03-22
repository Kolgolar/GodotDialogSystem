extends DefaultNode

class_name SetterNode

export(NodePath) onready var var_name = get_node(var_name) as LineEdit
export(NodePath) onready var var_value = get_node(var_value) as LineEdit


func _ready():
	type = "SETTER"


func set_data(graph_edit : GraphEdit, data : Dictionary, id_name : String) -> void:
	var_name.text = data["var_name"]
	var_value.text = data["var_value"]


func gen_data(graph_edit : GraphEdit) -> Dictionary:
	var data := {}
	data["var_name"] = var_name.text
	data["var_value"] = var_value.text
	data["go_to"] = []
	for connection in graph_edit.get_connection_list():
		if connection["from"] == name:
			data["go_to"].append(str(graph_edit.get_node(connection["to"]).id))
	return data
