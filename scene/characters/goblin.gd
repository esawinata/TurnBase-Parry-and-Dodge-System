extends CharacterBody2D

var max_hp: int = Global.monster_data[Global.Monster.GOBLIN]["max_hp"]
var current_hp: int = max_hp
var defense: int = Global.monster_data[Global.Monster.GOBLIN]["defense"]  # Baru
var characters_stats: Control

func _ready() -> void:
	pass

# Fungsi untuk take damage (akan dipanggil saat player attack)
func take_damage(amount: int) -> void:
	var actual_damage = max(0, amount - defense)
	current_hp -= actual_damage
	if characters_stats:
		characters_stats.update_enemy_health(current_hp)  # Ganti ke update_enemy_health
		if current_hp <= 0:
			print("Goblin defeated!")

# Fungsi untuk heal (opsional)
func heal(amount: int) -> void:
	current_hp += amount
	if characters_stats:
		characters_stats.update_health(current_hp)
