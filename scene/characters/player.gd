extends CharacterBody2D

var max_health: int = Global.player_data[Global.Player.CIFER]["max_health"]
var current_health: int = max_health
var max_stamina: int = Global.player_data[Global.Player.CIFER]["max_stamina"]
var current_stamina: int = max_stamina
var max_rage: int = Global.player_data[Global.Player.CIFER]["max_rage"]
var current_rage: int = 0
var defense: int = Global.player_data[Global.Player.CIFER]["defense"]
var characters_stats: Control
@onready var attack_area: Area2D = $AttackArea  
var tween: Tween
var stamina_ui: Control  
var rage_ui: Control     

func _ready() -> void:
	if not attack_area:
		print("Warning: AttackArea not found in player scene!")
	attack_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape.extents = Vector2(50, 50)
	attack_area.add_child(collision_shape)
	add_child(attack_area)

# Fungsi untuk take damage (akan dipanggil saat enemy attack)
func take_damage(amount: int, is_blocked: bool = false, block_press_time: int = 0) -> bool:  # Tambah return bool
	var actual_damage = amount
	var parried = false
	if is_blocked:
		var time_diff = Time.get_ticks_msec() - block_press_time
		if time_diff <= Global.PARRY_WINDOW_TIME:  # Parry window
			actual_damage = 0
			# Parry: Damage ke enemy dan gain rage
			get_parent().goblin_instance.take_damage(Global.PARRY_DAMAGE_TO_ENEMY)
			gain_rage(Global.PARRY_RAGE_GAIN)
			print("Parry! Dealt " + str(Global.PARRY_DAMAGE_TO_ENEMY) + " damage to enemy. Rage + " + str(Global.PARRY_RAGE_GAIN))
			parried = true
		else:
			# Block biasa: Kurangi damage
			actual_damage = int(amount * Global.BLOCK_DAMAGE_REDUCTION)
			print("Blocked! Damage reduced to " + str(actual_damage))
	current_health -= actual_damage
	if characters_stats:
		characters_stats.update_health(current_health)
	if current_health <= 0:
		print("Player defeated!")
	return parried

# Fungsi untuk heal (opsional, untuk item)
func heal(amount: int) -> void:
	current_health += amount
	if characters_stats:
		characters_stats.update_health(current_health)
	

# Fungsi untuk gain rage (dipanggil saat hit/parry musuh)
func gain_rage(amount: int) -> void:
	current_rage = min(current_rage + amount, max_rage)
	if rage_ui:
		rage_ui.update_rage(current_rage)  # Update UI
		print("Rage: " + str(current_rage) + "/" + str(max_rage))
# Fungsi untuk use stamina (untuk dodge)
func use_stamina(amount: int) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		if stamina_ui:
			stamina_ui.update_stamina(current_stamina)  # Update UI
			return true
	return false

# Fungsi untuk regenerate stamina per turn
func regenerate_stamina(amount: int = 20) -> void:
	current_stamina = min(current_stamina + amount, max_stamina)
	print("Stamina: " + str(current_stamina) + "/" + str(max_stamina))  # Debug
	
# Fungsi untuk perform attack (dipanggil dari battle.gd)
func perform_attack(target: CharacterBody2D, damage: int) -> void:
	var target_pos = target.global_position  # Posisi goblin
	var start_pos = global_position  # Posisi awal player
	
	# Tween maju ke target
	tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.5)  # Maju dalam 0.5 detik
	tween.tween_callback(func(): 
		print("Checking hit at target position")
		check_hit(target, damage)
		)  # Cek hit setelah maju
	tween.tween_interval(0.2)
	tween.tween_property(self, "global_position", start_pos, 0.5)  # Kembali

# Fungsi cek hit via collision
func check_hit(target: CharacterBody2D, damage: int) -> void:
	var overlapping = attack_area.get_overlapping_areas()  # Cek overlap dengan Area2D goblin
	if overlapping.size() > 0:  # Jika overlap, hit
		target.take_damage(damage)
		gain_rage(5)  # Gain rage per hit
		print("Hit! Damage: ", damage)
	else:
		print("Miss!")

# Fungsi end attack (callback untuk ganti turn)
func end_attack() -> void:
	regenerate_stamina()  # Regenerate stamina per turn
	# Signal ke battle.gd untuk ganti turn (opsional, atau langsung set di battle.gd)
	get_parent().current_turn = get_parent().Turn.ENEMY  # Asumsi battle.gd adalah parent
	# TODO: Trigger enemy turn nanti
	
