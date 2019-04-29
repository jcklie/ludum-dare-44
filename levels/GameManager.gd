extends Node2D

var levels = [
	preload("res://levels/Arena.tscn")
]

var level_class = "res://levels/Level.tscn"

var MAX_PLAYERS = 3

# Game State
var current_level_scene
var current_level
var number_of_players = 2
var players = {}

func start_random_level():
	current_level_scene = levels[randi() % levels.size()]
	get_tree().change_scene(level_class)
	
	players = {}

		
 