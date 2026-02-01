extends Button

var state
var type
signal press(state, type)

func _on_pressed() -> void:
	press.emit(state, type)

func setup(menu_state: Global.State,  button_type, button_text: String):
	text = button_text
	state = menu_state
	type = button_type
