extends DefaultNode

class_name StartNode

signal on_delete

func _ready():
	type = "START"


func gen_data(graph_edit : GraphEdit) -> Dictionary:
	var data := {}
	data["go_to"] = []
	for connection in graph_edit.get_connection_list():
		if connection["from"] == name:
			data["go_to"].append(str(graph_edit.get_node(connection["to"]).id))
	return data

	
func _on_GraphNode_close_request() -> void:
	emit_signal("on_delete")
	queue_free()