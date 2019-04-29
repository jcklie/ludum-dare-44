extends Node2D

var levels = [
	preload("res://levels/Arena.tscn")
]

var level_class = "res://levels/Level.tscn"
var winscreen_class = "res://winscreen/WinScreen.tscn"

var MAX_PLAYERS = 3

# Game State
var current_level_scene
var current_level
var number_of_players = 2
var players = {}
var life_players = MAX_PLAYERS
var winning_player = -1
var winning_currency = ""

signal game_over

func _ready():
	connect("game_over", AudioEngine, "_on_game_over")

func start_random_level():
	current_level_scene = levels[randi() % levels.size()]
	get_tree().change_scene(level_class)
	
	players = {}
	life_players = MAX_PLAYERS
	
func _on_player_death():
	life_players -= 1
	
	if life_players == 1:
		emit_signal("game_over")
		
		for p in players.values():
			if not p.dead:
				winning_player = p.player_id
				winning_currency = p.currency
		get_tree().change_scene(winscreen_class)
		
	
		
		

		
 