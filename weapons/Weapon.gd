extends Node2D

var player

var Projectile
var MaxFireDelay
var Velocity : float
var Damage : int

var fireDelay : float = 0

signal weapon_fired(name)
signal weapon_reload(name)

func _ready():
	connect("weapon_fired", AudioEngine, "_on_weapon_fired")
	connect("weapon_reload", AudioEngine, "_on_weapon_reload")

func shoot(delta):
	if fireDelay > 0:
		fireDelay -= delta
		
		if fireDelay <= 0:
			emit_signal("weapon_reload", name)
		return
		
	var newProjectile = Projectile.instance()
	newProjectile.position = player.global_position
	newProjectile.rotation = player.direction.angle()
	newProjectile.velocity = player.direction.normalized() * Velocity
	newProjectile.player_id = player.player_id
	newProjectile.damage = Damage
	
	get_tree().get_root().add_child(newProjectile)
	fireDelay = MaxFireDelay
	
	emit_signal("weapon_fired", name)		
	






