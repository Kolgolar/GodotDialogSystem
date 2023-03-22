extends DefaultNode

export(NodePath) onready var condition_var = get_node(condition_var) as LineEdit

const TRUE_PORT_ID = 0
const FALSE_PORT_ID = 1

func _ready():
	type = "CONDITION"


func set_data(graph_edit : GraphEdit, data : Dictionary, id_name : String) -> void:
	condition_var.text = data["var_name"]



func gen_data(graph_edit : GraphEdit) -> Dictionary:
	var data := {}
	data["var_name"] = condition_var.text
	# data["type"] = type
	# data["title"] = short_title
	# data["offset_x"] = offset.x
	# data["offset_y"] = offset.y
	data["go_to_true"] = []
	data["go_to_false"] = []
	# print(graph_edit.get_connection_list())
	for connection in graph_edit.get_connection_list():
		if connection["from"] == name:
			var needed_arr : String
			match connection["from_port"]:
				TRUE_PORT_ID:
					needed_arr = "go_to_true"
				FALSE_PORT_ID:
					needed_arr = "go_to_false"
				_:
					printerr("Output port error!")
			data[needed_arr].append(str(graph_edit.get_node(connection["to"]).id))
	return data