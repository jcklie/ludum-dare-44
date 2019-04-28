extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	play("cash_register")

func play(sfx):
	get_node(sfx).play()

func _on_weapon_fired(name):
	var name_to_sound = {
		"Minigun": "minigun_fired"}
	if not name in name_to_sound:
		return
	var sound = name_to_sound[name]
	play(sound)

func _on_weapon_reload(name):
	var name_to_sound = {
		"Crossbow": "crossbow_reload"}
	if not name in name_to_sound:
		return
	play(name_to_sound[name])

func _on_player_hurt():
	play("player_hurt")

func _on_player_death():
	play("player_death")