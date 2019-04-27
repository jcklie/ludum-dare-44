extends Area2D

var velocity : Vector2
var player_id: int
var damage: int

onready var notifier = get_node("Notifier")

func _ready():
	connect("body_entered", self, "_on_body_enter")
	notifier.connect("screen_exited", self, "_on_screen_exited")
	
	set_collision_layer_bit(0, true)
	
func _process(delta):
	move(delta)

func move(delta):
	global_position += velocity * delta
	
func _on_body_enter(body):
	if body.get("player_id") and body.player_id != player_id:
		body.damage(damage)

func _on_screen_exited():	
	queue_free()
