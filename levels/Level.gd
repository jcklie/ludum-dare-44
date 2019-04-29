extends Node2D

var player_class = preload("res://player/Player.tscn")

func _ready():
	var level_scence = GameManager.current_level_scene
	var level = level_scence.instance()
	GameManager.current_level = level
	
	add_child(level)
	
	for i in GameManager.MAX_PLAYERS:
		var id = i + 1
		var player = player_class.instance()
		player.player_id = id
		player.currency = i
		
		level.add_child(player)
		player.position = player.get_random_valid_position()
		
		if id > GameManager.number_of_players:
			player.is_ai = true
		
		GameManager.players[id] = player
		player.connect("player_death", GameManager, "_on_player_death")
		
		player.init()