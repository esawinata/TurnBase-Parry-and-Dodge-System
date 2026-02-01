extends Control

var grid_button_scene = preload("res://scene/UI/grid_button.tscn")
var list_button_scene = preload("res://scene/UI/list_button.tscn")
const main_buttons = {
	Global.State.ATTACK: 'Attack',
	Global.State.MASKED_MODE: 'Masked Mode',
	Global.State.ITEM: 'Item',
	Global.State.RUN: 'Run', 
}
var current_state: Global.State: set = state_handler

func _ready() -> void:
	current_state = Global.State.MAIN

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		current_state = Global.State.MAIN

func create_grid_buttons(state: Global.State, data: Dictionary):
	for i in $GridContainer.get_children():
		i.queue_free()
	for key in data:
		var grid_button = grid_button_scene.instantiate() as Button
		grid_button.setup(state, key, data[key])
		$GridContainer.add_child(grid_button)
		grid_button.connect('press', button_handler)
	await get_tree().process_frame
	$GridContainer.get_child(0).grab_focus()
	
func create_list_button(state: Global.State, data:Array):
	for i in $ScrollContainer/VBoxContainer.get_children():
		i.queue_free()
	for i in data:
		var list_button = list_button_scene.instantiate()
		$ScrollContainer/VBoxContainer.add_child(list_button)
		list_button.setup(state, i)
		list_button.connect('press', button_handler)
	await get_tree().process_frame
	$ScrollContainer.get_child(0).grab_focus()

signal attack_selected(attack_type)
signal masked_mode_requested
signal item_selected(item_type)  # Signal baru
func button_handler(state, type):
	if state == Global.State.MAIN:
		if type == Global.State.MASKED_MODE:
			masked_mode_requested.emit()
		else:
			current_state = type
	elif state == Global.State.ATTACK:
		attack_selected.emit(type)
		print("Attack selected: " + str(type))
	elif state == Global.State.MASKED_MODE:
		attack_selected.emit(type)
		print("Masked Attack selected: " + str(type))
	elif state == Global.State.ITEM:  # Tambahkan ini
		item_selected.emit(type)
		print("Item selected: " + str(type))

signal state_changed(new_state: Global.State)
func state_handler(value):
	state_changed.emit(value)  # Tambahkan ini di awal
	current_state = value
	match value:
		Global.State.ATTACK:
			var player_attacks = Global.player_data[Global.current_player]['attacks']
			print(player_attacks)
			create_grid_buttons(Global.State.ATTACK, {
				player_attacks[0]: Global.attack_data[player_attacks[0]]['name'],
				player_attacks[1]: Global.attack_data[player_attacks[1]]['name'],
				player_attacks[2]: Global.attack_data[player_attacks[2]]['name'],
				player_attacks[3]: Global.attack_data[player_attacks[3]]['name']
				})
			$GridContainer.show()
			$ScrollContainer.hide()
		Global.State.MAIN :
			create_grid_buttons(Global.State.MAIN, main_buttons)
			$GridContainer.show()
			$ScrollContainer.hide()
		Global.State.ITEM :
			create_list_button(Global.State.ITEM, Global.items)
			$GridContainer.hide()
			$ScrollContainer.show()
		Global.State.MASKED_MODE:
			var mask_attacks = Global.player_data[Global.current_player]['maskattack']
			print(mask_attacks)
			create_grid_buttons(Global.State.MASKED_MODE, {
				mask_attacks[0]: Global.mask_attack_data[mask_attacks[0]]['name'],
				mask_attacks[1]: Global.mask_attack_data[mask_attacks[1]]['name'],
				mask_attacks[2]: Global.mask_attack_data[mask_attacks[2]]['name'],
				mask_attacks[3]: Global.mask_attack_data[mask_attacks[3]]['name']
				})
			$GridContainer.show()
			$ScrollContainer.hide()
		Global.State.RUN:
			get_tree().quit()
