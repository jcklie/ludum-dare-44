extends Node2D

onready var player = get_parent()

var projectile = preload("res://weapons/ArrowProjectile.tscn")
var MaxFireDelay = .25

var fireDelay : float = 0
var velocity : float = 400

func shoot(delta):
	if fireDelay > 0:
		fireDelay -= 1.0 * delta
		return
		
	var newProjectile = projectile.instance()
	newProjectile.position = player.global_position
	newProjectile.rotation = player.direction.angle()
	newProjectile.velocity = player.direction.normalized() * velocity
	newProjectile.add_collision_exception_with(player)

	get_tree().get_root().add_child(newProjectile)
	fireDelay = MaxFireDelay
	
	
		
	






