extends Node2D

var player

var Projectile
var MaxFireDelay
var Velocity : float
var Damage : int
var MaxBullets : int

var fireDelay : float = 0
var reloaded : bool = true
var live_bullets : int = 0

signal weapon_fired(name, source)
signal weapon_reload(name, source)

func _ready():
	connect("weapon_fired", AudioEngine, "_on_weapon_fired")
	connect("weapon_reload", AudioEngine, "_on_weapon_reload")

func _process(delta):
	fireDelay -= delta
	if fireDelay <= 0 and not reloaded:
		reloaded = true
		emit_signal("weapon_reload", name, self)
		
func shoot(delta):
	if fireDelay > 0 || live_bullets >= MaxBullets:
		return
		
	var newProjectile = Projectile.instance()
	newProjectile.position = player.global_position
	newProjectile.rotation = player.direction.angle()
	newProjectile.velocity = player.direction.normalized() * Velocity
	newProjectile.player_id = player.player_id
	newProjectile.damage = Damage
	newProjectile.connect("bullet_died", self, "_on_bullet_died")
	live_bullets += 1
	
	get_tree().get_root().add_child(newProjectile)
	fireDelay = MaxFireDelay
	reloaded = false
	
	emit_signal("weapon_fired", name, self)

func _on_bullet_died():
	live_bullets -= 1






