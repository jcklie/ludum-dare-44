extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	play("cash_register")

func play(sfx, source: Node2D = null):
	var sound_node = get_node(sfx)
	if source != null:
		sound_node.global_position = source.global_position
	sound_node.play()

func _on_weapon_fired(name, source: Node2D = null):
	var name_to_sound = {
		"Minigun": "minigun_fired"}
	if not name in name_to_sound:
		return
	play(name_to_sound[name], source)

func _on_weapon_reload(name, source: Node2D = null):
	var name_to_sound = {
		"Crossbow": "crossbow_reload"}
	if not name in name_to_sound:
		return
	play(name_to_sound[name], source)

func _on_player_hurt(source: Node2D = null):
	play("player_hurt", source)

func _on_player_death(source: Node2D = null):
	play("player_death")