extends DefaultNode

class_name LineNode

export(NodePath) onready var text = get_node(text) as TextEdit
export(NodePath) onready var localization_id = get_node(localization_id) as LineEdit
export(NodePath) onready var choice_name = get_node(choice_name) as LineEdit
export(NodePath) onready var custom_char_name = get_node(custom_char_name) as LineEdit
export(NodePath) onready var character_drop = get_node(character_drop) as OptionButton

var characters = [
	"Player",
	"Char1",
	"Char2",
	"Char3",
	"Char4",
	"Char5",
	"Char6",
	"Char7",
	"Char8",
]


func _ready():
	type = "LINE"
	var char_index = 0
	for ch in characters:
		character_drop.add_item(ch, char_index)
		char_index += 1 


func set_data(graph_edit : GraphEdit, data : Dictionary, id_name : String) -> void:
	id = int(id_name)
	offset.x  = data["offset_x"]
	offset.y = data["offset_y"]
	character_drop.text = data["character"]
	text.text = data["text"]
	if "choice_name" in data:
		choice_name.text = data["choice_name"]
	if "localization_id" in data:
		localization_id.text = data["localization_id"]
	if "custom_char_name" in data:
		custom_char_name.text = data["custom_char_name"]
	
	# var regex = RegEx.new()
	# regex.compile("(?<=[A-Z]_).+")
	# var short_title = regex.search(title).strings[0]
	_update_title_text(data["title"])


func gen_data(graph_edit : GraphEdit) -> Dictionary:
	var line_data := {}
	line_data["go_to"] = []
	# line_data["id"] = id
	line_data["type"] = type
	line_data["title"] = short_title
	line_data["offset_x"] = offset.x
	line_data["offset_y"] = offset.y
	line_data["character"] = character_drop.text
	line_data["text"] = text.text
	if not choice_name.text.empty():
		line_data["choice_name"] = choice_name.text
	if not localization_id.text.empty():
		line_data["localization_id"] = localization_id.text
	if not custom_char_name.text.empty():
		line_data["custom_char_name"] = custom_char_name.text
	for connection in graph_edit.get_connection_list():
		if connection["from"] == name:
			line_data["go_to"].append(str(graph_edit.get_node(connection["to"]).id))
	
	return {str(id) : line_data}
