extends Node2D

onready var player = get_parent()

var Projectile
var MaxFireDelay = .25
var Velocity : float = 400

var fireDelay : float = 0

func shoot(delta):
	if fireDelay > 0:
		fireDelay -= 1.0 * delta
		return
		
	var newProjectile = Projectile.instance()
	newProjectile.position = player.global_position
	newProjectile.rotation = player.direction.angle()
	newProjectile.velocity = player.direction.normalized() * Velocity
	newProjectile.set_collision_mask_bit(player.player_id, 0)

	get_tree().get_root().add_child(newProjectile)
	fireDelay = MaxFireDelay
	
	
		
	






