extends "res://weapons/Weapon.gd"

func _ready():
	Projectile = preload("res://weapons/crossbow/CrossbowProjectile.tscn")
	MaxFireDelay = .5
	Velocity = 800
	Damage = 35