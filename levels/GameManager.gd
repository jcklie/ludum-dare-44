extends Node2D

var levels = [
	#preload("res://levels/Arena.tscn")
	# preload("res://levels/EmptyArena.tscn"),
	preload("res://levels/BlockFortKnox.tscn"),
	preload("res://levels/MyFirstMap.tscn"),
	preload("res://levels/SmallRiver.tscn"),
]

var level_class = "res://levels/Level.tscn"
var winscreen_class = "res://winscreen/WinScreen.tscn"
var menu_class = "res://menu/MainMenu.tscn"

var MAX_PLAYERS = 3

# Game State
var current_level_scene
var current_level
var number_of_players = 2
var players = {}
var life_players = []
var winning_player = -1
var winning_currency = ""

var last_map_idx = -1

signal game_over

func _ready():
	connect("game_over", AudioEngine, "_on_game_over")

func start_random_level():
	seed(OS.get_system_time_msecs())
	var next_level_idx = get_random_map_idx()
	last_map_idx = next_level_idx
	
	current_level_scene = levels[next_level_idx]
	get_tree().change_scene(level_class)
	
	players = {}
	life_players = []
	
func _on_player_death(player_id):
	life_players.erase(player_id)
	
	if life_players.size() == 1:
		emit_signal("game_over")
		
		var p = players[life_players[0]]
		winning_player = p.player_id
		winning_currency = p.currency
		get_tree().change_scene(winscreen_class)
		
func show_menu():
	get_tree().change_scene(menu_class)
		
func get_random_map_idx():
	var result = 0
	for i in range(100):
		result = randi() % levels.size()
		if result != last_map_idx:
			return result
			
	return result
		