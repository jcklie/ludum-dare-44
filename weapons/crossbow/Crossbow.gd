extends "res://weapons/Weapon.gd"

func _ready():
	Projectile = preload("res://weapons/crossbow/CrossbowProjectile.tscn")
	MaxFireDelay = 1.0
	Velocity = 800