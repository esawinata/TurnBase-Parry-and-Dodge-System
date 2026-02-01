extends Button

var state
var type
signal press(state, type)

func setup(menu_state, button_type):
	var data = Global.item_data
	$HBoxContainer/Label.text = data[button_type]['name']
	$HBoxContainer/TextureRect .texture = load(data[button_type]['icon'])
	state = menu_state
	type = button_type
func _on_pressed() -> void:
	press.emit(state, type)
