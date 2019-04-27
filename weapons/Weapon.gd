extends Node2D

var player

var Projectile
var MaxFireDelay
var Velocity : float
var Damage : int

var fireDelay : float = 0

func shoot(delta):
	if fireDelay > 0:
		fireDelay -= 1.0 * delta
		return
		
	var newProjectile = Projectile.instance()
	newProjectile.position = player.global_position
	newProjectile.rotation = player.direction.angle()
	newProjectile.velocity = player.direction.normalized() * Velocity
	newProjectile.player_id = player.player_id
	newProjectile.damage = Damage
	
	get_tree().get_root().add_child(newProjectile)
	fireDelay = MaxFireDelay
	
	
		
	






