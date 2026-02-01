extends Node

enum State {MAIN, ATTACK, MASKED_MODE, ITEM, RUN}

enum Player {CIFER}
enum Monster {GOBLIN}
enum Attack {SLASH, STAB, SPIN, HEAVY}
enum MaskAttack {SHADOW_SLASH, SOUL_BURST, VOID_PIERCE, DARK_WAVE}
enum Item {POTION, ELIXIR, MUSHROOM, POISON}

const player_data : Dictionary[Player, Dictionary] = {
	Player.CIFER: {
		"name": "Cifer",
		"max_health": 100,
		"max_stamina": 100,  # Stamina untuk dodge
		"max_rage": 300,     # Rage meter untuk masked mode
		"defense": 5,        # Defense untuk block/parry
		"attacks": [
			Attack.SLASH,
			Attack.STAB,
			Attack.SPIN,
			Attack.HEAVY],
		"maskattack": [
			MaskAttack.SHADOW_SLASH,
			MaskAttack.SOUL_BURST,
			MaskAttack.VOID_PIERCE,
			MaskAttack.DARK_WAVE
		]
	}
}

const monster_data : Dictionary[Monster, Dictionary] = {
	Monster.GOBLIN: {
		"name": "Goblin",
		"max_hp": 700,       
		"attack": 8,
		"defense": 3,
		"speed": 5,
		"attacks": [Attack.SLASH]
	}
}


const attack_data : Dictionary[Attack, Dictionary] = {
	Attack.SLASH: {
		"name": "Slash",
		"amount": 10,
		"animation": "",
		"target": 1
	},

	Attack.STAB: {
		"name": "Stab",
		"amount": 12,
		"animation": "",
		"target": 1
	},

	Attack.SPIN: {
		"name": "Spin Attack",
		"amount": 8,
		"animation": "",
		"target": 1
	},

	Attack.HEAVY: {
		"name": "Heavy Strike",
		"amount": 18,
		"animation": "",
		"target": 1
	}
}

const mask_attack_data : Dictionary[MaskAttack, Dictionary] = {
	MaskAttack.SHADOW_SLASH: {
		"name": "Shadow Slash",
		"amount": 45,
		"animation": "",
		"target": 1
	},

	MaskAttack.SOUL_BURST: {
		"name": "Soul Burst",
		"amount": 50,
		"animation": "",
		"target": 1
	},

	MaskAttack.VOID_PIERCE: {
		"name": "Void Pierce",
		"amount": 55,
		"animation": "",
		"target": 1
	},

	MaskAttack.DARK_WAVE: {
		"name": "Dark Wave",
		"amount": 60,
		"animation": "",
		"target": 1
	}
}

const item_data : Dictionary[Item, Dictionary] = {
	Item.POTION: {
		'name': "Potion",
		'amount': 30,
		'icon': "res://graphics/item sprites/potion.png",
		'target': 0
	},

	Item.ELIXIR: {
		'name': "Elixir",
		'amount': 60,
		'icon': "res://graphics/item sprites/elixir.png",
		'target': 0
	},

	Item.MUSHROOM: {
		'name': "Mushroom",
		'amount': 15,
		'icon': "res://graphics/item sprites/mushroom.png",
		'target': 0
	},
	
	Item.POISON: {
		'name': "Poison",
		'amount': 20,
		'icon': "res://graphics/item sprites/poison.png",
		'target': 1
	}
}

var current_player : Player
var current_enemy : Monster

var player = [Player.CIFER]
var monster = [Monster.GOBLIN]

var items = [
	Item.POTION,
	Item.MUSHROOM,
	Item.ELIXIR,
	Item.POISON
]

const DODGE_STAMINA_COST = 20
const BLOCK_DAMAGE_REDUCTION = 0.5  # 50% reduction for block
const PARRY_DAMAGE_TO_ENEMY = 5
const PARRY_RAGE_GAIN = 10
const DODGE_WINDOW_TIME = 0.5  # Detik window untuk dodge
const PARRY_WINDOW_TIME = 200  # ms window untuk parry
