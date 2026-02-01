
extends Control

@onready var name_label: Label = $CanvasLayer/VBoxContainer/Label
@onready var health_bar: ProgressBar = $CanvasLayer/VBoxContainer/ProgressBar
@onready var rage_name_label: Label = $CanvasLayer/VBoxContainer2/Label
@onready var rage_bar: ProgressBar = $CanvasLayer/VBoxContainer2/ProgressBar
@onready var stamina_name_label: Label = $CanvasLayer/VBoxContainer3/Label
@onready var stamina_bar: ProgressBar = $CanvasLayer/VBoxContainer3/ProgressBar
@onready var enemy_label: Label = $CanvasLayer2/VBoxContainer/Label
@onready var enemy_health_bar: ProgressBar = $CanvasLayer2/VBoxContainer/ProgressBar

# Var untuk Player
var character_name: String = "Unknown"
var max_health: int = 100
var current_health: int = 100
var max_stamina: int = 100  # Ambil dari Global
var current_stamina: int = 100
var max_rage: int = 100
var current_rage: int = 0

# Var untuk Enemy
var enemy_name: String = "Unknown"
var enemy_max_health: int = 100
var enemy_current_health: int = 100

func _ready() -> void:
	update_ui()
	update_enemy_ui()

# Fungsi untuk set data awal Player
func setup(character_name: String, max_hp: int, current_hp: int) -> void:
	self.character_name = character_name
	max_health = max_hp
	current_health = current_hp
	max_stamina = Global.player_data[Global.current_player]["max_stamina"]  # Ambil dari Global
	max_rage = Global.player_data[Global.current_player]["max_rage"]
	update_ui()

# Fungsi untuk set data awal Enemy
func setup_enemy(enemy_name: String, max_hp: int, current_hp: int) -> void:
	self.enemy_name = enemy_name
	enemy_max_health = max_hp
	enemy_current_health = current_hp
	update_enemy_ui()

# Fungsi untuk update health Player
func update_health(new_health: int) -> void:
	current_health = clamp(new_health, 0, max_health)
	update_ui()

# Fungsi untuk update stamina Player
func update_stamina(new_stamina: int) -> void:
	current_stamina = clamp(new_stamina, 0, max_stamina)
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina

# Fungsi untuk update rage Player
func update_rage(new_rage: int) -> void:
	current_rage = clamp(new_rage, 0, max_rage)
	rage_bar.max_value = max_rage
	rage_bar.value = current_rage

# Fungsi untuk update health Enemy
func update_enemy_health(new_health: int) -> void:
	enemy_current_health = clamp(new_health, 0, enemy_max_health)
	update_enemy_ui()

# Update UI Player
func update_ui() -> void:
	name_label.text = character_name
	health_bar.max_value = max_health
	health_bar.value = current_health
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina
	rage_bar.max_value = max_rage
	rage_bar.value = current_rage

# Update UI Enemy
func update_enemy_ui() -> void:
	enemy_label.text = enemy_name
	enemy_health_bar.max_value = enemy_max_health
	enemy_health_bar.value = enemy_current_health
