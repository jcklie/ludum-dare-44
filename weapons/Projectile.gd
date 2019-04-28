extends Area2D

var velocity : Vector2
var player_id: int
var damage: int

onready var notifier = get_node("Notifier")

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
			queue_free()
	else:
		if body.get("health"):
			body.damage(damage)
		queue_free()

func _on_screen_exited():	
	queue_free()
