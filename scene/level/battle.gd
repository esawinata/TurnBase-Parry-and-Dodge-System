extends Node2D

@onready var characters_stats_ui: Control = $Widget/characters_stats
@onready var input_menu: Control = $Widget/InputMenu

var player_instance: CharacterBody2D
var goblin_instance: CharacterBody2D

enum Turn {PLAYER, ENEMY}
var current_turn: Turn = Turn.PLAYER
var is_busy: bool = false

# Tambahan untuk dodge/block
var player_blocking: bool = false
var player_dodging: bool = false
var block_press_time: int = 0  # Timestamp saat block pressed
var dodge_window_active: bool = false
var dodge_window_timer: float = 0.0
var enemy_attack_active: bool = false  # Flag baru: aktif selama enemy attack

# Tambahan untuk enemy combo
var enemy_combo_count: int = 0  # Jumlah attack dalam combo (random 1-3)
var parry_count: int = 0  # Track berapa kali parry dalam combo

# Tambahan untuk masked mode
var is_masked_mode: bool = false
var masked_moves_left: int = 0  # Counter untuk moves di masked mode

func _ready() -> void:
	Global.current_player = Global.player[0]
	if not Global.current_enemy:
		Global.current_enemy = Global.monster[0]
	
	var player_scene = preload("res://scene/characters/player.tscn")
	var goblin_scene = preload("res://scene/characters/goblin.tscn")
	
	player_instance = player_scene.instantiate()
	goblin_instance = goblin_scene.instantiate()
	
	add_child(player_instance)
	add_child(goblin_instance)
	
	# Atur posisi
	player_instance.position = Vector2(200, 300)
	goblin_instance.position = Vector2(600, 300)
	
	 # Assign UI ke player dan goblin
	player_instance.characters_stats = characters_stats_ui
	goblin_instance.characters_stats = characters_stats_ui
	
	# Setup UI Player
	if characters_stats_ui:
		characters_stats_ui.setup(
			Global.player_data[Global.current_player]["name"],
			Global.player_data[Global.current_player]["max_health"],
			player_instance.current_health
			)
		# Assign UI untuk stamina dan rage
		player_instance.stamina_ui = characters_stats_ui
		player_instance.rage_ui = characters_stats_ui
	
	# Setup UI Enemy
	if characters_stats_ui:
		characters_stats_ui.setup_enemy(
			Global.monster_data[Global.current_enemy]["name"],
			Global.monster_data[Global.current_enemy]["max_hp"],
			goblin_instance.current_hp
			)
	
	input_menu.attack_selected.connect(_on_attack_selected)
	input_menu.state_changed.connect(_on_state_changed)  # Connect signal baru
	input_menu.hide()  # Sembunyikan dulu
	input_menu.item_selected.connect(_on_item_selected)
	input_menu.masked_mode_requested.connect(_on_masked_mode_requested)
	# Mulai turn player
	start_player_turn()

func _process(delta: float) -> void:
	if dodge_window_active:
		dodge_window_timer -= delta
		if dodge_window_timer <= 0:
			dodge_window_active = false

func _on_item_selected(item_type: Global.Item) -> void:
	if current_turn == Turn.PLAYER and not is_busy:
		is_busy = true
		input_menu.hide()
		use_item(item_type)

func use_item(item_type: Global.Item) -> void:
	var item_data = Global.item_data[item_type]
	print("Using item: " + item_data['name'])
	
	if item_data['target'] == 0:  # Target player (heal)
		player_instance.heal(item_data['amount'])
		print("Player healed for " + str(item_data['amount']))
	else:  # Target enemy (damage)
		goblin_instance.take_damage(item_data['amount'])
		print("Enemy damaged for " + str(item_data['amount']))
	# Hapus item dari inventory
	Global.items.erase(item_type)
	print("Item removed from inventory")
	
	# Efek visual sederhana (opsional)
	if item_data['target'] == 0:
		player_instance.modulate = Color.GREEN
		await get_tree().create_timer(0.5).timeout
		player_instance.modulate = Color.WHITE
	else:
		goblin_instance.modulate = Color.PURPLE
		await get_tree().create_timer(0.5).timeout
		goblin_instance.modulate = Color.WHITE
	
	# Cek victory
	if goblin_instance.current_hp <= 0:
		print("Victory!")
		return
	
	# End turn
	start_enemy_turn()

func _on_masked_mode_requested() -> void:
	if player_instance.current_rage >= player_instance.max_rage:
		input_menu.current_state = Global.State.MASKED_MODE
		is_masked_mode = true
		masked_moves_left = 5
		print("Masked Mode activated! Moves left: " + str(masked_moves_left))
	else:
		print("Not enough rage to enter Masked Mode!")
		input_menu.current_state = Global.State.MAIN

func _input(event: InputEvent) -> void:
	# Block bisa dilakukan kapan saja, tidak hanya saat enemy attack
	if event.is_action_pressed("Block"):
		print("Block pressed")
		player_blocking = true
		block_press_time = Time.get_ticks_msec()
		player_instance.modulate = Color(0.5, 0.5, 1.0, 1.0)  # Biru muda
		
	elif event.is_action_released("Block"):
		print("Block released")
		player_blocking = false
		player_instance.modulate = Color(1, 1, 1, 1)
		
	# Ubah kondisi: aktif selama enemy attack berlangsung
	if enemy_attack_active : 
		print("Enemy attack active, checking dodge/block")  # Debug, hapus nanti
		if event.is_action_pressed("Dodge") and dodge_window_active:
			print("Dodge pressed in window")  # Debug, hapus nanti
			if player_instance.use_stamina(Global.DODGE_STAMINA_COST):
				player_dodging = true
				# Animate dodge: geser player ke kiri (atau kanan, sesuaikan)
				var original_pos = player_instance.position
				var dodge_pos = original_pos + Vector2(-50, 0)  # Geser 50px ke kiri
				var tween_dodge = create_tween()
				tween_dodge.tween_property(player_instance, "position", dodge_pos, 0.2)
				tween_dodge.tween_interval(0.3)  # Tunggu sebentar
				tween_dodge.tween_property(player_instance, "position", original_pos, 0.2)
				print("Dodged!")  # Sudah ada
			else:
				print("Not enough stamina to dodge!")

func _on_state_changed(new_state: Global.State) -> void:
	if new_state == Global.State.MASKED_MODE:
		if player_instance.current_rage < player_instance.max_rage:
			print("Not enough rage to enter Masked Mode!")
			input_menu.current_state = Global.State.MAIN
			return
		else:
			is_masked_mode = true
			masked_moves_left = 5  # Set counter ke 5
			print("Masked Mode activated! Moves left: " + str(masked_moves_left))
	elif new_state == Global.State.MAIN:
		is_masked_mode = false
		masked_moves_left = 0

func start_player_turn() -> void:
	current_turn = Turn.PLAYER
	input_menu.show()
	is_busy = false
	player_dodging = false  # Reset dodge
	print("Player's turn")

func start_enemy_turn() -> void:
	current_turn = Turn.ENEMY
	input_menu.hide()
	is_busy = true
	
	# Randomize combo count (1-3 attacks)
	enemy_combo_count = randi_range(1, 3)
	parry_count = 0  # Reset parry count
	print("Enemy combo: " + str(enemy_combo_count) + " attacks")
	
	dodge_window_active = true
	dodge_window_timer = Global.DODGE_WINDOW_TIME
	enemy_attack_active = true  # Aktifkan flag
	enemy_attack()

func enemy_attack() -> void:
	print("Enemy's turn")  # Sudah ada, tapi biarkan
	var enemy_damage = Global.monster_data[Global.current_enemy]["attack"]
	
	for i in range(enemy_combo_count):
		print("Enemy attack " + str(i+1) + " of " + str(enemy_combo_count))
		
		var original_pos = goblin_instance.position
		var target_pos = player_instance.position
		
		var tween = create_tween()
		tween.tween_property(goblin_instance, "position", target_pos, 0.3)
		tween.tween_callback(func(): 
			if not player_dodging:
				var was_parried = player_instance.take_damage(enemy_damage, player_blocking, block_press_time)
				if was_parried:
					parry_count += 1
			else:
				print("Attack dodged!")
			)
		tween.tween_interval(0.2)
		tween.tween_property(goblin_instance, "position", original_pos, 0.3)
		
		# Tunggu tween selesai sebelum attack berikutnya
		await tween.finished
		
		# Reset dodge per attack
		player_dodging = false
		
		# Jika player mati, stop
		if player_instance.current_health <= 0:
			print("Game Over!")
			return
	
	# Setelah semua attack selesai
	enemy_attack_active = false  # Matikan flag
	
	# Cek bonus jika semua 3 attack diparry
	if enemy_combo_count == 3 and parry_count == 3:
		print("Perfect Parry Combo! Bonus damage to enemy!")
		goblin_instance.take_damage(20)  # Bonus damage 20
	
	# Reset states
	player_blocking = false
	
	start_player_turn()

func _on_attack_selected(attack_type) -> void:  # Variant
	if current_turn == Turn.PLAYER and not is_busy:
		is_busy = true
		input_menu.hide()
		player_attack(attack_type)

func player_attack(attack_type) -> void:
	var damage: int
	if is_masked_mode:
		damage = Global.mask_attack_data[attack_type]["amount"]
		print("Player using Masked Attack: " + Global.mask_attack_data[attack_type]['name'] + " for " + str(damage) + " damage")
		
		# Kurangi counter
		masked_moves_left -= 1
		print("Moves left in Masked Mode: " + str(masked_moves_left))
		
		# Jika counter habis, reset rage dan keluar masked mode
		if masked_moves_left <= 0:
			player_instance.current_rage = 0
			if player_instance.rage_ui:
				player_instance.rage_ui.update_rage(0)
			is_masked_mode = false
			masked_moves_left = 0
			input_menu.current_state = Global.State.MAIN
			print("Masked Mode ended. Rage reset.")
	else:
		damage = Global.attack_data[attack_type]["amount"]
		print("Player attacking with " + Global.attack_data[attack_type]['name'] + " for " + str(damage) + " damage")
	
	# Panggil perform_attack dengan callback
	player_instance.perform_attack(goblin_instance, damage)
	
	# Efek visual: goblin menjadi merah selama 0.1 detik saat kena hit
	var original_color = goblin_instance.modulate
	var tween_hit = create_tween()
	tween_hit.tween_property(goblin_instance, "modulate", Color.RED, 1.00)  # Cepat ke merah
	tween_hit.tween_property(goblin_instance, "modulate", original_color, 0.05)  # Kembali ke warna asli
	
	# Tunggu animasi selesai (asumsikan 1.5 detik untuk animasi maju-mundur)
	await get_tree().create_timer(1.5).timeout
	
	# Cek apakah musuh sudah mati
	if goblin_instance.current_hp <= 0:
		print("Victory!")
		# TODO: Tambahkan logika kemenangan
		return
	
	# Ganti turn ke enemy
	start_enemy_turn()
