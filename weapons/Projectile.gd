extends Area2D

var velocity : Vector2
var player_id: int
var damage: int
var dead = false

onready var notifier = get_node("Notifier")

signal bullet_died

func _ready():
	connect("body_entered", self, "_on_body_enter")
	
	notifier.connect("screen_exited", self, "_on_screen_exited")
	
func _process(delta):
	move(delta)

func move(delta):
	global_position += velocity * delta
	
func _on_body_enter(body):
	if body.get("player_id"):
		if body.player_id != player_id:
			body.damage(damage)
			die()
	else:
		if body.get("health"):
			body.damage(damage)
		die()

func _on_screen_exited():	
	die()
	
func die():
	if not dead:
		emit_signal("bullet_died")
		queue_free()
		dead = true
